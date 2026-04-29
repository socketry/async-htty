# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "protocol/htty"

require "async/http/protocol/http2"

module Async
	module HTTY
		module Protocol
			module HTTY
				def self.client(stream, settings: ::Async::HTTP::Protocol::HTTP2::CLIENT_SETTINGS)
					stream = ::Protocol::HTTY::Stream.open(stream, bootstrap: :read)
					
					client = ::Async::HTTP::Protocol::HTTP2::Client.new(stream)
					client.send_connection_preface(settings)
					client.start_connection
					
					return client
				end
				
				def self.server(stream, settings: ::Async::HTTP::Protocol::HTTP2::SERVER_SETTINGS)
					stream = ::Protocol::HTTY::Stream.open(stream, bootstrap: :write)
					
					server = ::Async::HTTP::Protocol::HTTP2::Server.new(stream)
					server.read_connection_preface(settings)
					server.start_connection
					
					return server
				end
				
				def self.names
					["htty"]
				end
			end
		end
	end
end
