# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "io/console"
require "protocol/http/middleware"

require_relative "protocol"

module Async
	module HTTY
		class Server < ::Protocol::HTTP::Middleware
			class RawInput
				INTERRUPT_CHARACTER = "\u0003".b

				def initialize(input)
					@input = input
				end

				def read(length = nil, *arguments)
					chunk = @input.read(length, *arguments)
					return chunk unless chunk&.include?(INTERRUPT_CHARACTER)

					raise Interrupt, "HTTY session interrupted"
				end

				def method_missing(name, *arguments, **options, &block)
					@input.public_send(name, *arguments, **options, &block)
				end

				def respond_to_missing?(name, include_private = false)
					@input.respond_to?(name, include_private) || super
				end
			end

			def self.for(**options, &block)
				self.new(block, **options)
			end

			def self.open(app = nil, input: $stdin, output: $stdout, task: ::Async::Task.current, **options, &block)
				app ||= block
				self.new(app, **options).accept(input: input, output: output, task: task)
			end

			def initialize(app, protocol: Protocol::HTTY)
				super(app)
				@protocol = protocol
			end

			attr :protocol

			def accept(input:, output:, task: ::Async::Task.current)
				with_raw_terminal(input) do
					connection = @protocol.server(input: RawInput.new(input), output: output)

					connection.each do |request|
						self.call(request)
					end

					task.children.each(&:wait)
				ensure
					connection&.close
				end
			end

			private

			def with_raw_terminal(input)
				if input.respond_to?(:tty?) && input.tty? && input.respond_to?(:raw)
					input.raw do
						yield
					end
				else
					yield
				end
			end
		end
	end
end