# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async"
require "io/console"
require "protocol/http/middleware"

require_relative "error"
require_relative "protocol"

module Async
	module HTTY
		class Server < ::Protocol::HTTP::Middleware
			def self.for(**options, &block)
				self.new(block, **options)
			end
			
			def self.with_raw_terminal(input, &block)
				if input.respond_to?(:tty?) && input.tty? && input.respond_to?(:raw)
					input.raw(&block)
				else
					block.call
				end
			end

			
			def self.open(app = nil, input: $stdin, output: $stdout, env: ENV, **options, &block)
				app ||= block
				server = self.new(app, **options)

				case env["HTTY"]
				when "0"
					raise DisabledError, "HTTY is disabled!"
				when nil
					$stderr.puts "HTTY is not supported by this environment, visit https://htty.dev for more information."
					raise UnsupportedError, "HTTY is not supported by this environment"
				end
				
				Sync do |task|
					with_raw_terminal(input) do
						stream = ::IO::Stream::Duplex(input, output)
						server.accept(stream, task: task)
					end
				end
			end
			
			def initialize(app, protocol: Protocol::HTTY)
				super(app)
				@protocol = protocol
			end
			
			attr :protocol
			
			def accept(stream, task: ::Async::Task.current)
				connection = @protocol.server(stream)
				
				connection.each do |request|
					self.call(request)
				end
				
				Array(task.children).each(&:wait)
			ensure
				if connection and !connection.closed?
					connection.send_goaway
					connection.close
				end
			end
		end
	end
end
