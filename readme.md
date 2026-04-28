# Async::HTTY

`async-htty` adapts `Protocol::HTTY::Stream` into an Async-compatible HTTP/2 connection so terminal sessions can host `Protocol::HTTP::Middleware` applications.

The first implementation keeps the layering explicit:

- `protocol-htty` owns the terminal-safe byte transport.
- `protocol-http2` owns the HTTP/2 wire semantics.
- `async-http` owns the HTTP request and response mapping.
- `async-htty` only connects those layers for one TTY session.