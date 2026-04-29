# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

module Async
	module HTTY
		class Error < StandardError
		end
		
		class UnsupportedError < Error
		end
		
		class DisabledError < UnsupportedError
		end
	end
end
