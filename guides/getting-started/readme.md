# Getting Started

This guide explains how to get started with `async-htty` as an Async-compatible runtime for HTTY sessions carrying plaintext HTTP/2 (`h2c`) over a DCS-bootstrapped raw terminal transport.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add async-htty
~~~

`async-htty` builds on a small stack:

- `protocol-htty` provides the HTTY bootstrap and raw byte transport.
- `protocol-http2` provides HTTP/2 wire semantics.
- `async-http` provides the Async-compatible HTTP connection layer.
- `async-htty` connects those pieces to one terminal session.

## When to Use Async::HTTY

Use `async-htty` when you already have a terminal session and want to serve an HTTP/2 application over HTTY without building a separate socket server.

This is useful when you want to:

- Run an HTTP/2 application inside a command process.
- Carry that application over stdin/stdout or a PTY.
- Keep the terminal visible while a higher-level tool attaches a browser surface or another HTTP/2 client.

`async-htty` does not define a new application protocol. It only adapts an HTTY-bootstrapped raw byte stream into an Async HTTP/2 server connection.

## Core Concepts

- {ruby Async::HTTY::Server} accepts an HTTY session over `input` and `output`.
- Your app remains a normal {ruby Protocol::HTTP::Middleware} application.
- HTTY handles bootstrap and raw transport takeover, while HTTP/2 still owns connection setup, requests, responses, and shutdown semantics.

## A Minimal Server

The smallest useful setup is a middleware app that writes a normal HTTP response and then serves it over the current terminal session:

~~~ ruby
require "async"
require "async/htty"
require "protocol/http/response"

app = Protocol::HTTP::Middleware.for do |request|
	Protocol::HTTP::Response[200, [["content-type", "text/plain"]], ["Hello World from HTTY\n"]]
end

Sync do
	Async::HTTY::Server.open(app)
end
~~~

This is the same basic structure used by [examples/hello_world.rb](../../examples/hello_world.rb).

## Serving HTML

Because the carried connection is just HTTP/2, your app can return HTML as easily as plain text:

~~~ ruby
require "async"
require "async/htty"
require "protocol/http/response"

app = Protocol::HTTP::Middleware.for do |request|
	body = <<~HTML
		<!DOCTYPE html>
		<html>
			<body>
				<h1>Hello from Async::HTTY</h1>
				<p>#{request.method} #{request.path}</p>
			</body>
		</html>
	HTML

	Protocol::HTTP::Response[200, [["content-type", "text/html; charset=utf-8"]], [body]]
end

Sync do
	Async::HTTY::Server.open(app)
end
~~~

For a more complete example, see [examples/browser_demo.rb](../../examples/browser_demo.rb).

## Custom Input and Output

By default, {ruby Async::HTTY::Server.open} uses `$stdin` and `$stdout`, but you can supply explicit streams if you are integrating with a PTY, pipes, or another transport wrapper:

~~~ ruby
Async::HTTY::Server.open(app, input: some_input, output: some_output)
~~~

The server will switch TTY input into raw mode when appropriate, emit the HTTY bootstrap on output, and then carry plain HTTP/2 bytes over the session.

## How Requests Flow

At a high level:

1. The command side emits the HTTY bootstrap and the terminal side accepts takeover.
2. An HTTP/2 client writes its connection preface and frames into the resulting raw HTTY stream.
3. `async-htty` adapts that stream into an Async HTTP/2 server connection.
4. Your middleware app receives a normal HTTP request and returns a normal HTTP response.

This keeps the layering explicit and makes each component easier to reason about.

## Running the Examples

From the repository root, you can run the included examples directly:

~~~ bash
$ ruby examples/hello_world.rb
$ ruby examples/browser_demo.rb
~~~

Those examples expect an HTTY-capable environment on the other side of the terminal session.

## Best Practices

- Keep your app as a normal {ruby Protocol::HTTP::Middleware} application.
- Let HTTY handle bootstrap and takeover, and let HTTP/2 handle connection semantics.
- Prefer explicit `input:` and `output:` streams when integrating with custom transports.
- Keep terminal-facing behavior simple; richer rendering belongs above HTTY, not inside it.

## Next Steps

- For the bootstrap rules and transport semantics, see the [Protocol::HTTY specification](https://socketry.github.io/protocol-htty/guides/specification/index).
- For lower-level bootstrap and transport details, see the [Protocol::HTTY getting started guide](https://socketry.github.io/protocol-htty/guides/getting-started/index).