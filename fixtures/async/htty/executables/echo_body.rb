# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/htty"
require "protocol/http/response"

app = Protocol::HTTP::Middleware.for do |request|
	Protocol::HTTP::Response[200, [["content-type", "application/octet-stream"]], request.body]
end

Async::HTTY::Server.open(app)
