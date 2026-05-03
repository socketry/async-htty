# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "pty"

module Async
	module HTTY
		class PTYStream
			def initialize(input, output)
				@input = input
				@output = output
				@buffer = +"".b
			end
			
			def read(length)
				while @buffer.bytesize < length
					@buffer << @input.readpartial(4096).b
				end
				
				data = @buffer.byteslice(0, length)
				@buffer = @buffer.byteslice(length, @buffer.bytesize) || +"".b
				
				return data
			rescue EOFError, Errno::EIO
				raise EOFError, "PTY closed"
			end
			
			def write(data)
				@output.write(data)
			end
			
			def flush
				@output.flush
			end
			
			def close
				@input.close rescue nil
				@output.close rescue nil
			end
			
			def closed?
				@input.closed?
			end
		end
	end
end
