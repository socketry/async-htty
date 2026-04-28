# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "stringio"
require "protocol/http/middleware"
require "async/htty"

describe Async::HTTY::Server do
	let(:server) {subject.new(Protocol::HTTP::Middleware::Okay)}

	it "exposes the HTTY protocol by default" do
		expect(server.protocol).to be == Async::HTTY::Protocol::HTTY
	end

	it "switches tty input into raw mode while accepting a session" do
		input = Object.new
		output = StringIO.new
		connection = Object.new
		protocol = Object.new
		task = Struct.new(:children).new([])

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

		def connection.each
		end

		def connection.close
		end

		protocol.define_singleton_method(:server) do |input:, output:|
			connection
		end

		server = subject.new(Protocol::HTTP::Middleware::Okay, protocol: protocol)
		server.accept(input: input, output: output, task: task)

		expect(input.raw_called?).to be == true
		expect(output.string).to be == ""
	end

	it "translates raw ctrl-c input into Interrupt" do
		input = Object.new
		output = StringIO.new
		protocol = Object.new
		task = Struct.new(:children).new([])

		def input.tty?
			true
		end

		def input.raw
			yield
		end

		def input.read(length = nil)
			@reads ||= ["\u0003".b]
			@reads.shift
		end

		protocol.define_singleton_method(:server) do |input:, output:|
			Struct.new(:input) do
				def each
					input.read(1)
				end

				def close
				end
			end.new(input)
		end

		server = subject.new(Protocol::HTTP::Middleware::Okay, protocol: protocol)

		expect do
			server.accept(input: input, output: output, task: task)
		end.to raise_exception(Interrupt, message: be =~ /interrupted/)
	end

	it "opens a server with default stdio-style arguments" do
		input = StringIO.new
		output = StringIO.new
		task = Struct.new(:children).new([])
		accepted = false

		server = Object.new
		server.define_singleton_method(:each) do
		end
		server.define_singleton_method(:close) do
		end

		protocol = Object.new
		protocol.define_singleton_method(:server) do |input:, output:|
			accepted = true
			server
		end

		subject.open(Protocol::HTTP::Middleware::Okay, input: input, output: output, task: task, protocol: protocol)

		expect(accepted).to be == true
		expect(output.string).to be == ""
	end
end