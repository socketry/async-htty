---
template: statement
duration: 10
transition: fade
---

emit a tiny, terminal-safe DCS sequence

# Translation

端末を壊さない小さなDCSシーケンスを1つ送るだけ

---

First, the command emits a short escape sequence — a Device Control String, or DCS. That is the kind of thing terminals are already designed to consume without rendering.
