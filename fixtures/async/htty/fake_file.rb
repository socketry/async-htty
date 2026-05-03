# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "stringio"

module Async
	module HTTY
		class FakeFile < StringIO
			def initialize(string = "", tty: false, state: nil)
				super(string)
				
				@tty = tty
				@state = state || {
					raw: false,
					raw_called: false,
					raw_exited: false
				}
				
				@reopen_events = []
				@reopened_to_null = false
			end
			
			attr_accessor :timeout
			attr :reopen_events
			
			def reopened_to_null?
				@reopened_to_null
			end
			
			def tty?
				@tty
			end
			
			def raw?
				@state[:raw]
			end
			
			def raw_called?
				@state[:raw_called]
			end
			
			def raw_exited?
				@state[:raw_exited]
			end
			
			def raw
				previous_raw = @state[:raw]
				
				@state[:raw] = true
				@state[:raw_called] = true
				
				yield
			ensure
				@state[:raw] = previous_raw
				@state[:raw_exited] = true
			end
			
			def dup
				copy = self.class.new(self.string.dup, tty: @tty, state: @state)
				copy.timeout = @timeout
				
				copy
			end
			
			def reopen(other)
				case other
				when String
					@reopen_events << :null
					@reopened_to_null = true
					
					self.string = +""
				when StringIO
					@reopen_events << :file
					@reopened_to_null = false
					
					self.string = other.string.dup
				else
					@reopen_events << :file
					@reopened_to_null = false
					
					self.string = other.read.to_s
				end
				
				self.rewind
				
				return self
			end
			
			def readable?
				!closed?
			end
			
			def wait_readable(duration = nil)
				true
			end
			
			def wait_writable(duration = nil)
				true
			end
			
			def read_nonblock(size, buffer, exception: false)
				if string = read(size)
					buffer.replace(string)
				elsif exception
					raise EOFError
				end
			end
		end
	end
end
