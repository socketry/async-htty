# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "protocol/htty"

require "async/http/protocol/http2"
require_relative "htty/server"

module Async
	module HTTY
		module Protocol
			module HTTY
				def self.client(stream, settings: ::Async::HTTP::Protocol::HTTP2::CLIENT_SETTINGS)
					mode = stream.read_bootstrap
					
					unless mode == ::Protocol::HTTY::Stream::RAW_MODE
						raise ::Protocol::HTTY::ProtocolError, "Expected HTTY bootstrap mode #{::Protocol::HTTY::Stream::RAW_MODE.inspect}, got #{mode.inspect}"
					end
					
					client = ::Async::HTTP::Protocol::HTTP2::Client.new(stream)
					client.send_connection_preface(settings)
					client.start_connection
					
					return client
				end
				
				def self.server(stream, settings: ::Async::HTTP::Protocol::HTTP2::SERVER_SETTINGS)
					stream.write_bootstrap
					
					server = Server.new(stream)
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
