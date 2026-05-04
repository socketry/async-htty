# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async"
require "protocol/http/body/writable"
require "protocol/http/request"
require "protocol/http/response"
require "protocol/http2"
require "protocol/http2/client"
require "protocol/http2/stream"
require "rbconfig"
require "async/htty"

require "async/htty/pty_stream"

class EchoResponseStream < Protocol::HTTP2::Stream
	attr :response_headers
	attr :body
	
	def initialize(...)
		super
		@response_headers = []
		@body = +"".b
	end
	
	def process_headers(frame)
		@response_headers = super
	end
	
	def process_data(frame)
		data = super
		@body << data.b if data
		return data
	end
end

class EchoClient < Protocol::HTTP2::Client
	def create_stream(id = next_stream_id)
		EchoResponseStream.create(self, id)
	end
end

describe Async::HTTY::Protocol::HTTY do
	let(:root) {File.expand_path("../../../..", __dir__)}
	let(:ruby_load_path) {File.join(root, "lib")}
	
	def make_pipes
		server_input, client_output = IO.pipe
		client_input, server_output = IO.pipe
		
		{
			server_input: server_input,
			server_output: server_output,
			client_input: client_input,
			client_output: client_output,
		}
	end
	
	def close_pipes(pipes)
		pipes.each_value do |io|
			io.close rescue nil
		end
	end
	
	def client_stream(pipes)
		Protocol::HTTY::Stream.new(pipes[:client_input], pipes[:client_output])
	end
	
	def server_stream(pipes)
		Protocol::HTTY::Stream.new(pipes[:server_input], pipes[:server_output])
	end
	
	def spawn_fixture(name)
		environment = {
			"HTTY" => "1",
			"RUBYLIB" => [ruby_load_path, ENV["RUBYLIB"]].compact.join(":"),
		}
		executable = File.join(root, "fixtures", "async", "htty", "executables", name)
		
		PTY.spawn(environment, RbConfig.ruby, executable)
	end
	
	def with_fixture(name)
		input, output, pid = spawn_fixture(name)
		input.binmode
		output.binmode
		
		stream = Async::HTTY::PTYStream.new(input, output)
		
		yield stream
	ensure
		stream&.close
		Process.wait(pid) rescue nil
	end
	
	it "can carry an HTTP/2 request over HTTY bootstrap and raw transport" do
		pipes = make_pipes
		
		server = Async::HTTY::Server.for do |request|
			Protocol::HTTP::Response[200, {}, ["Hello World"]]
		end
		
		Sync do |task|
			server_task = task.async do
				server.accept(server_stream(pipes))
			end
			
			client = subject.client(client_stream(pipes))
			response = client.call(Protocol::HTTP::Request["GET", "/"])
			
			expect(response.status).to be == 200
			expect(response.read).to be == "Hello World"
		ensure
			client&.close
			server_task&.stop
			close_pipes(pipes)
		end
	end
	
	it "round trips all byte values over a real PTY" do
		payload = (0x00..0xff).to_a.pack("C*")
		
		with_fixture("echo_body.rb") do |stream|
			stream = Protocol::HTTY::Stream.new(stream.input, stream.output)
			stream.read_bootstrap
			
			framer = Protocol::HTTP2::Framer.new(stream)
			client = EchoClient.new(framer)
			client.send_connection_preface
			
			request = client.create_stream
			request.send_headers(
				[
					[":method", "POST"],
					[":path", "/echo"],
					[":scheme", "http"],
					[":authority", "htty.local"],
					["content-length", payload.bytesize.to_s],
					["content-type", "application/octet-stream"],
				]
			)
			request.send_data(payload)
			request.send_data(nil)
			
			until request.closed?
				client.read_frame
			end
			
			expect(request.response_headers.to_h[":status"]).to be == "200"
			expect(request.body).to be == payload
		ensure
			client&.send_goaway
			client&.close
		end
	end
	
	it "returns from accept when the client sends GOAWAY while a response body is active" do
		pipes = make_pipes
		body = Protocol::HTTP::Body::Writable.new
		
		Sync do |task|
			request_started = Async::Notification.new
			server_finished = Async::Notification.new
			
			server = Async::HTTY::Server.for do |request|
				request_started.signal
				Protocol::HTTP::Response[200, {}, body]
			end
			
			server_task = task.async do
				server.accept(server_stream(pipes))
			ensure
				server_finished.signal
			end
			
			stream = client_stream(pipes)
			stream.read_bootstrap
			framer = Protocol::HTTP2::Framer.new(stream)
			client = Protocol::HTTP2::Client.new(framer)
			client.send_connection_preface
			
			request = client.create_stream
			request.send_headers(
				[[":method", "GET"], [":path", "/"], [":scheme", "http"], [":authority", "htty.local"]],
				Protocol::HTTP2::END_STREAM
			)
			
			request_started.wait
			client.send_goaway
			
			task.with_timeout(1) do
				server_finished.wait
			end
			
			frame = task.with_timeout(1) do
				loop do
					frame = framer.read_frame(client.local_settings.maximum_frame_size)
					break frame if frame.is_a?(Protocol::HTTP2::GoawayFrame)
				end
			end
			
			expect(frame).to be(:is_a?, Protocol::HTTP2::GoawayFrame)
		ensure
			body.close
			client&.close
			server_task&.stop
			close_pipes(pipes)
		end
	end
	
	it "ignores terminal noise before the HTTY bootstrap" do
		pipes = make_pipes
		
		Sync do |task|
			pipes[:server_output].write("terminal noise\eP+reset:test\e\\")
			pipes[:server_output].flush
			
			server_task = task.async do
				subject.server(server_stream(pipes))
			end
			
			client = subject.client(client_stream(pipes))
			
			expect(client).not.to be(:closed?)
		ensure
			client&.close
			server_task&.stop
			close_pipes(pipes)
		end
	end
	
	it "treats command exit after bootstrap without GOAWAY as an abort" do
		pipes = make_pipes
		
		pipes[:server_output].write("\eP+Hraw\e\\")
		pipes[:server_output].close
		
		Sync do
			expect do
				subject.client(client_stream(pipes))
			end.to raise_exception(EOFError)
		ensure
			close_pipes(pipes)
		end
	end
end
