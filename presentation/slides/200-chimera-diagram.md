---
template: diagram
duration: 18
transition: fade
---

<div style="left: 5%; top: 8%; width: 90%; text-align: center; font-size: 1.4em;">
  one PTY, two surfaces
  <div style="opacity: 0.7; margin-top: 0.4em;">1つのPTY、2つの画面</div>
</div>

<div style="left: 5%; top: 30%; width: 42%; height: 45%; background: #1e1e1e; color: #ddd; border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; font-family: monospace; padding: 1rem; box-sizing: border-box;">
  <div>terminal pane</div>
  <div style="opacity: 0.6; margin-top: 0.4em;">$ ruby app.rb</div>
  <div style="opacity: 0.7; margin-top: 0.6em;">端末ペイン</div>
</div>

<div style="left: 53%; top: 30%; width: 42%; height: 45%; background: var(--surface-light); border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; padding: 1rem; box-sizing: border-box;">
  <div><strong>browser pane</strong></div>
  <div style="opacity: 0.6; margin-top: 0.4em;">live HTTP/2 to the command</div>
  <div style="opacity: 0.7; margin-top: 0.6em;">ブラウザペイン</div>
</div>

<div style="left: 5%; top: 82%; width: 90%; text-align: center; opacity: 0.85;">
  Chimera owns the PTY and routes raw h2c bytes to the embedded browser
  <div style="opacity: 0.7; margin-top: 0.4em;">ChimeraがPTYを所有し、生のh2cバイトを内蔵ブラウザに振り分ける</div>
</div>

---

What you end up with is a single PTY backing two surfaces. The terminal pane still works as a terminal. The browser pane is talking HTTP/2 to the same command process, over the same bytes.

No second socket. No second port. One process, one PTY, two surfaces.
