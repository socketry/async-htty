---
template: diagram
duration: 21
transition: fade
---

<div style="left: 5%; top: 10%; width: 90%; text-align: center; font-size: 1.4em;">
  the takeover
  <div style="opacity: 0.7; margin-top: 0.4em;">切り替えの流れ</div>
</div>

<div style="left: 5%; top: 38%; width: 25%; height: 24%; background: var(--surface-light); border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
  <strong>command process</strong>
  <div style="opacity: 0.7; margin-top: 0.3em;">コマンド側</div>
</div>

<div style="left: 37.5%; top: 38%; width: 25%; height: 24%; background: var(--surface-light); border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
  <strong>terminal / PTY</strong>
  <div style="opacity: 0.7; margin-top: 0.3em;">端末・PTY</div>
</div>

<div style="left: 70%; top: 38%; width: 25%; height: 24%; background: var(--surface-light); border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;">
  <strong>host</strong>
  <div style="opacity: 0.7; margin-top: 0.3em;">ホスト</div>
</div>

<div style="left: 30%; top: 44%; width: 7.5%; font-size: 1.6em; text-align: center; opacity: 0.6;">→</div>
<div style="left: 62.5%; top: 44%; width: 7.5%; font-size: 1.6em; text-align: center; opacity: 0.6;">→</div>

<div style="left: 5%; top: 70%; width: 90%; text-align: center; opacity: 0.85;">
  <strong>1.</strong> command emits <code>ESC P +H raw ESC \\</code>
  &nbsp;&nbsp;<strong>2.</strong> terminal switches to raw
  &nbsp;&nbsp;<strong>3.</strong> raw h2c bytes flow end-to-end
  <div style="opacity: 0.7; margin-top: 0.5em;">①コマンドがDCSを送出 → ②端末が生モードへ → ③以降は素のh2c</div>
</div>

---

Here is the full flow.

The command process emits the DCS to the terminal. The terminal — or rather, whatever is hosting the terminal session on the other end — recognises the DCS and switches into raw mode.

From there, the byte stream is just HTTP/2, in both directions. The bootstrap is one-way; everything after is bidirectional.
