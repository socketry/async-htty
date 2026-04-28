# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/htty/version"

describe Async::HTTY do
	it "has a version number" do
		expect(Async::HTTY::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
end