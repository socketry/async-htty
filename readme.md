# Async::HTTY

`async-htty` adapts `Protocol::HTTY::Stream` into an Async-compatible HTTP/2 connection so terminal sessions can bootstrap HTTY and host `Protocol::HTTP::Middleware` applications over the resulting raw byte stream.

[![Development Status](https://github.com/socketry/async-htty/workflows/Test/badge.svg)](https://github.com/socketry/async-htty/actions?workflow=Test)

## Usage

Please see the [project documentation](https://socketry.github.io/async-htty/) for more details.

  - [Getting Started](https://socketry.github.io/async-htty/guides/getting-started/index) - This guide explains how to get started with `async-htty` as an Async-compatible runtime for HTTY sessions carrying plaintext HTTP/2 (`h2c`) over a DCS-bootstrapped raw terminal transport.

## Releases

Please see the [project releases](https://socketry.github.io/async-htty/releases/index) for all releases.

### v0.1.0

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Running Tests

To run the test suite:

``` shell
bundle exec sus
```

### Making Releases

To make a new release:

``` shell
bundle exec bake gem:release:patch # or minor or major
```

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
