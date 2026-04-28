# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async"
require "protocol/http/request"
require "protocol/http/response"
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

	it "can carry an HTTP/2 request over HTTY framing" do
		pipes = make_pipes

		server = Async::HTTY::Server.for do |request|
			Protocol::HTTP::Response[200, {}, ["Hello World"]]
		end

		Sync do |task|
			server_task = task.async do
				server.accept(input: pipes[:server_input], output: pipes[:server_output])
			end

			client = subject.client(input: pipes[:client_input], output: pipes[:client_output])
			response = client.call(Protocol::HTTP::Request["GET", "/"])

			expect(response.status).to be == 200
			expect(response.read).to be == "Hello World"
		ensure
			client&.close
			server_task&.stop
			pipes.each_value(&:close)
		end
	end
end