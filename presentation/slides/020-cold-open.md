---
template: statement
duration: 25
transition: fade
---

No new protocol. No side socket. Just HTTP/2, over the same bytes your shell is already using.

# Translation

新しいプロトコルもない。別ソケットもいらない。シェルが既に流しているバイト列の上を、ただHTTP/2が走るだけ。

---

Before you start guessing what HTTY might be, let me head off the obvious wrong answers.

It is not a new protocol. There is no extra socket on the side. There is no second port being opened. It is just plain HTTP/2, flowing over the same bytes your shell is already pushing through stdin and stdout.

That is the whole trick. The rest of this talk is about what makes that possible, and what it lets you do.
