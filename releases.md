# Releases

## Unreleased

  - Suppress errors from `send_goaway` during connection cleanup to prevent shutdown exceptions from propagating.

## v0.3.0

  - Pass explicit terminal input and output endpoints into `Protocol::HTTY::Stream`, avoiding buffered duplex reads across the HTTY HTTP/2 transport.
  - Expect the HTTY protocol adapter to receive a prepared `Protocol::HTTY::Stream` instance before performing bootstrap and HTTP/2 setup.

## v0.2.1

  - Send a server-side GOAWAY when the HTTY client closes an HTTP/2 session, allowing terminal clients to detach cleanly.
  - Add PTY coverage for binary request/response bodies across the full byte range.

## v0.2.0

  - Reopen `stdin`, `stdout`, and `stderr` to null devices to prevent output from interfering with HTTY's byte stream.
  - Guard against non-TTY input streams, which are not supported by HTTY.

## v0.1.0

  - Initial implementation.
