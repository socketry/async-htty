# frozen_string_literal: true

require "async"
require "async/htty"
require "protocol/http/response"

app = Protocol::HTTP::Middleware.for do |request|
	Protocol::HTTP::Response[200, [["content-type", "text/plain"]], ["Hello World from HTTY\n"]]
end

Sync do
	Async::HTTY::Server.open(app)
	sleep 1
end