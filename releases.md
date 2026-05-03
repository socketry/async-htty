# Releases

## Unreleased

  - Reopen `stdin`, `stdout`, and `stderr` to null devices to prevent output from interfering with HTTY's byte stream.
  - Guard against non-TTY input streams, which are not supported by HTTY.

## v0.1.0

  - Initial implementation.
