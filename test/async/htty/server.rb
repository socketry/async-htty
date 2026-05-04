# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "protocol/http/middleware"
require "async/htty"
require "async/htty/fake_file"

describe Async::HTTY::Server do
	let(:server) {subject.new(Protocol::HTTP::Middleware::Okay)}
	let(:env) {{"HTTY" => "1"}}
	let(:error) {Async::HTTY::FakeFile.new}
	
	it "exposes the HTTY protocol by default" do
		expect(server.protocol).to be == Async::HTTY::Protocol::HTTY
	end
	
	it "switches tty input into raw mode while accepting a session" do
		input = Async::HTTY::FakeFile.new(tty: true)
		output = Async::HTTY::FakeFile.new
		connection = Object.new
		protocol = Object.new
		
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
		
		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, error: error, env: env, protocol: protocol)
		
		expect(input).to be(:raw_called?)
		expect(input).not.to be(:raw?)
		expect(output.string).to be == ""
	end
	
	it "leaves raw mode if protocol setup fails" do
		input = Async::HTTY::FakeFile.new(tty: true)
		output = Async::HTTY::FakeFile.new
		protocol = Object.new
		
		protocol.define_singleton_method(:server) do |_stream|
			raise EOFError, "aborted"
		end
		
		expect do
			subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, error: error, env: env, protocol: protocol)
		end.to raise_exception(EOFError, message: be =~ /aborted/)
		
		expect(input).to be(:raw_exited?)
		expect(input).not.to be(:raw?)
	end
	
	it "reopens stdio streams while accepting and restores them afterwards" do
		input = Async::HTTY::FakeFile.new("request", tty: true)
		output = Async::HTTY::FakeFile.new
		error = Async::HTTY::FakeFile.new("diagnostics")
		connection = Object.new
		protocol = Object.new
		reopened_to_null = nil
		duplex_input = nil
		duplex_output = nil
		
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
			reopened_to_null = [input.reopened_to_null?, output.reopened_to_null?, error.reopened_to_null?]
			duplex_input = stream.input
			duplex_output = stream.output
			
			stream.write("response", flush: true)
			
			connection
		end
		
		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, error: error, env: env, protocol: protocol)
		
		expect(reopened_to_null).to be == [true, true, true]
		expect(duplex_input).not.to be == input
		expect(duplex_output).not.to be == output
		expect(duplex_input.string).to be == "request"
		
		expect(input).not.to be(:reopened_to_null?)
		expect(output).not.to be(:reopened_to_null?)
		expect(error).not.to be(:reopened_to_null?)
		
		expect(input.reopen_events).to be == [:null, :file]
		expect(output.reopen_events).to be == [:null, :file]
		expect(error.reopen_events).to be == [:null, :file]
		
		expect(input.string).to be == "request"
		expect(output.string).to be == "response"
		expect(error.string).to be == "diagnostics"
	end
	
	it "restores stdio streams if protocol setup fails" do
		input = Async::HTTY::FakeFile.new("request", tty: true)
		output = Async::HTTY::FakeFile.new("response")
		error = Async::HTTY::FakeFile.new("diagnostics")
		protocol = Object.new
		
		protocol.define_singleton_method(:server) do |_stream|
			raise EOFError, "aborted"
		end
		
		expect do
			subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, error: error, env: env, protocol: protocol)
		end.to raise_exception(EOFError, message: be =~ /aborted/)
		
		expect(input).not.to be(:reopened_to_null?)
		expect(output).not.to be(:reopened_to_null?)
		expect(error).not.to be(:reopened_to_null?)
		
		expect(input.reopen_events).to be == [:null, :file]
		expect(output.reopen_events).to be == [:null, :file]
		expect(error.reopen_events).to be == [:null, :file]
		
		expect(input.string).to be == "request"
		expect(output.string).to be == "response"
		expect(error.string).to be == "diagnostics"
	end
	
	it "sends command-side GOAWAY before closing the connection" do
		input = Async::HTTY::FakeFile.new(tty: true)
		output = Async::HTTY::FakeFile.new
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
		
		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, error: error, env: env, protocol: protocol)
		
		expect(events).to be == [:goaway, :close]
	end
	
	it "opens a server with default stdio-style arguments" do
		input = Async::HTTY::FakeFile.new(tty: true)
		output = Async::HTTY::FakeFile.new
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
		
		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, error: error, env: env, protocol: protocol)
		
		expect(accepted).to be == true
		expect(output.string).to be == ""
	end
	
	it "raises a typed error when HTTY is disabled" do
		expect do
			subject.open(Protocol::HTTP::Middleware::Okay, input: Async::HTTY::FakeFile.new, output: Async::HTTY::FakeFile.new, error: error, env: {"HTTY" => "0"})
		end.to raise_exception(Async::HTTY::DisabledError, message: be =~ /disabled/)
		
		expect(Async::HTTY::DisabledError).to be < Async::HTTY::UnsupportedError
	end

	it "raises a typed error when stdin is not a tty" do
		input = Async::HTTY::FakeFile.new
		output = Async::HTTY::FakeFile.new

		expect do
			subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, error: error, env: env)
		end.to raise_exception(Async::HTTY::UnsupportedError, message: be =~ /TTY input/)

		expect(input.reopen_events).to be == []
		expect(output.reopen_events).to be == []
	end
	
	it "prints help and raises a typed error when HTTY is not advertised" do
		error_output = StringIO.new
		original_stderr = $stderr
		
		begin
			$stderr = error_output
			
			expect do
				subject.open(Protocol::HTTP::Middleware::Okay, input: Async::HTTY::FakeFile.new, output: Async::HTTY::FakeFile.new, env: {})
			end.to raise_exception(Async::HTTY::UnsupportedError, message: be =~ /not supported/)
		ensure
			$stderr = original_stderr
		end
		
		expect(error_output.string).to be(:include?, "https://htty.dev")
	end

	it "opens a server within its own async context when no task is provided" do
		input = Async::HTTY::FakeFile.new(tty: true)
		output = Async::HTTY::FakeFile.new
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

		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, error: error, env: env, protocol: protocol)

		expect(accepted).to be == true
	end
end
