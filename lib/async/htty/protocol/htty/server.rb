# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/http/protocol/http2/server"

module Async
	module HTTY
		module Protocol
			module HTTY
				class Server < ::Async::HTTP::Protocol::HTTP2::Server
					def receive_goaway(frame)
						super
						
						if framer = self.framer
							self.send_goaway
							framer.flush
						end
					end
				end
			end
		end
	end
end
