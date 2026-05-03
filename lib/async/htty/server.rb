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
			
			def self.open(app = nil, input: $stdin, output: $stdout, error: $stderr, env: ENV, **options, &block)
				app ||= block
				server = self.new(app, **options)

				case env["HTTY"]
				when "0"
					raise DisabledError, "HTTY is disabled!"
				when nil
					$stderr.puts "HTTY is not supported by this environment, visit https://htty.dev for more information."
					raise UnsupportedError, "HTTY is not supported by this environment"
				end

				unless input.respond_to?(:tty?) && input.tty?
					raise UnsupportedError, "HTTY requires a TTY input stream"
				end
				
				original_input = input.dup
				original_output = output.dup
				original_error = error.dup
				
				stream = ::IO::Stream::Duplex(original_input, original_output)
				input.reopen(File::NULL)
				output.reopen(File::NULL)
				error.reopen(File::NULL)
				
				Sync do |task|
					with_raw_terminal(original_input) do
						server.accept(stream, task: task)
					end
				end
				
			ensure
				if original_input
					input.reopen(original_input)
				end
				
				if original_output
					output.reopen(original_output)
				end
				
				if original_error
					error.reopen(original_error)
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
