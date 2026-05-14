---
template: statement
duration: 21
transition: fade
---

It's just a PTY.

So SSH works too.

# Translation

結局はただのPTY。
だからSSH越しでもそのまま動く。

---

Here is something worth noticing.

The HTTY stream communicates over a PTY. Where that PTY actually *lives* — local terminal, an SSH session, a container — does not matter.

Which means: the same setup works over any existing terminal shell, local or remote, including SSH. No port forwarding. No second connection required.
