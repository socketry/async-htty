---
template: code
duration: 19
focus: 11-11
title: raw mode → bootstrap → HTTP/2
---

```ruby
require "async"
require "async/htty"
require "protocol/http/response"

app = Protocol::HTTP::Middleware.for do |request|
  Protocol::HTTP::Response[200,
    [["content-type", "text/plain"]],
    ["Hello World from HTTY\n"]]
end

Async::HTTY::Server.open(app)
```

## Translation

生モード → ブートストラップ → HTTP/2

---

And `Async::HTTY::Server.open` is the line that ties everything together.

It does three things, in order: puts the terminal into raw mode, emits the bootstrap we just looked at, and then runs an HTTP/2 server over the resulting byte stream — dispatching each incoming request through your middleware.