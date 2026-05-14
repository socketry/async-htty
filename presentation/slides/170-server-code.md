---
template: code
duration: 20
transition: fade
focus: 5-9
title: a normal middleware app, served over the terminal
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

ターミナル越しの普通のミドルウェアアプリ

---

This is the entire hello-world server. Six lines of real code.

Build a normal `Protocol::HTTP::Middleware` app — the same thing you would write for any Ruby HTTP server. Hand it to `Async::HTTY::Server.open`. Done.

Nothing about the app is HTTY-specific. HTTY is just the transport underneath.
