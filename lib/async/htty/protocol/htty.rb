# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "protocol/htty"

require "async/http/protocol/http2"

module Async
	module HTTY
		module Protocol
			module HTTY
				def self.client(input:, output:, settings: ::Async::HTTP::Protocol::HTTP2::CLIENT_SETTINGS)
					stream = ::Protocol::HTTY::Stream.new(input, output)

					client = ::Async::HTTP::Protocol::HTTP2::Client.new(stream)
					client.send_connection_preface(settings)
					client.start_connection
					client
				end

				def self.server(input:, output:, settings: ::Async::HTTP::Protocol::HTTP2::SERVER_SETTINGS)
					stream = ::Protocol::HTTY::Stream.new(input, output)

					server = ::Async::HTTP::Protocol::HTTP2::Server.new(stream)
					server.read_connection_preface(settings)
					server.start_connection
					server
				end

				def self.names
					["htty"]
				end
			end
		end
	end
end