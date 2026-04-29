# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async"
require "protocol/http/request"
require "protocol/http/response"
require "protocol/http2"
require "async/htty"

describe Async::HTTY::Protocol::HTTY do
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
		IO::Stream::Duplex(pipes[:client_input], pipes[:client_output])
	end
	
	def server_stream(pipes)
		IO::Stream::Duplex(pipes[:server_input], pipes[:server_output])
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
