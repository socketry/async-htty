# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "stringio"
require "protocol/http/middleware"
require "async/htty"

describe Async::HTTY::Server do
	let(:server) {subject.new(Protocol::HTTP::Middleware::Okay)}
	let(:env) {{"HTTY" => "1"}}
	
	it "exposes the HTTY protocol by default" do
		expect(server.protocol).to be == Async::HTTY::Protocol::HTTY
	end
	
	it "switches tty input into raw mode while accepting a session" do
		input = Object.new
		output = StringIO.new
		connection = Object.new
		protocol = Object.new
		input.instance_variable_set(:@raw_called, false)
		
		def input.tty?
			true
		end
		
		def input.raw
			@raw_called = true
			yield
		end
		
		def input.raw_called?
			@raw_called
		end
		
		def input.timeout
		end
		
		def connection.each
		end
		
		def connection.closed?
			false
		end
		
		def connection.send_goaway
		end
		
		def connection.close
		end
		
		protocol.define_singleton_method(:server) do |stream|
			connection
		end
		
		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, env: env, protocol: protocol)
		
		expect(input.raw_called?).to be == true
		expect(output.string).to be == ""
	end
	
	it "leaves raw mode if protocol setup fails" do
		input = Object.new
		output = StringIO.new
		protocol = Object.new
		input.instance_variable_set(:@raw_exited, false)
		
		def input.tty?
			true
		end
		
		def input.raw
			yield
		ensure
			@raw_exited = true
		end
		
		def input.raw_exited?
			@raw_exited
		end
		
		def input.timeout
		end
		
		protocol.define_singleton_method(:server) do |stream|
			raise EOFError, "aborted"
		end
		
		expect do
			subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, env: env, protocol: protocol)
		end.to raise_exception(EOFError, message: be =~ /aborted/)
		
		expect(input.raw_exited?).to be == true
	end
	
	it "sends command-side GOAWAY before closing the connection" do
		input = StringIO.new
		output = StringIO.new
		connection = Object.new
		protocol = Object.new
		events = []
		
		def connection.each
		end
		
		connection.define_singleton_method(:closed?) do
			false
		end
		
		connection.define_singleton_method(:send_goaway) do
			events << :goaway
		end
		
		connection.define_singleton_method(:close) do
			events << :close
		end
		
		protocol.define_singleton_method(:server) do |stream|
			connection
		end
		
		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, env: env, protocol: protocol)
		
		expect(events).to be == [:goaway, :close]
	end
	
	it "opens a server with default stdio-style arguments" do
		input = StringIO.new
		output = StringIO.new
		accepted = false
		
		server = Object.new
		server.define_singleton_method(:each) do
		end
		server.define_singleton_method(:closed?) do
			false
		end
		server.define_singleton_method(:send_goaway) do
		end
		server.define_singleton_method(:close) do
		end
		
		protocol = Object.new
		protocol.define_singleton_method(:server) do |stream|
			accepted = true
			server
		end
		
		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, env: env, protocol: protocol)
		
		expect(accepted).to be == true
		expect(output.string).to be == ""
	end
	
	it "raises a typed error when HTTY is disabled" do
		expect do
			subject.open(Protocol::HTTP::Middleware::Okay, input: StringIO.new, output: StringIO.new, env: {"HTTY" => "0"})
		end.to raise_exception(Async::HTTY::DisabledError, message: be =~ /disabled/)
		
		expect(Async::HTTY::DisabledError).to be < Async::HTTY::UnsupportedError
	end
	
	it "prints help and raises a typed error when HTTY is not advertised" do
		error_output = StringIO.new
		original_stderr = $stderr
		
		begin
			$stderr = error_output
			
			expect do
				subject.open(Protocol::HTTP::Middleware::Okay, input: StringIO.new, output: StringIO.new, env: {})
			end.to raise_exception(Async::HTTY::UnsupportedError, message: be =~ /not supported/)
		ensure
			$stderr = original_stderr
		end
		
		expect(error_output.string).to be(:include?, "https://htty.dev")
	end

	it "opens a server within its own async context when no task is provided" do
		input = StringIO.new
		output = StringIO.new
		accepted = false

		server = Object.new
		server.define_singleton_method(:each) do
		end
		server.define_singleton_method(:closed?) do
			false
		end
		server.define_singleton_method(:send_goaway) do
		end
		server.define_singleton_method(:close) do
		end

		protocol = Object.new
		protocol.define_singleton_method(:server) do |stream|
			accepted = true
			server
		end

		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, env: env, protocol: protocol)

		expect(accepted).to be == true
	end
end
