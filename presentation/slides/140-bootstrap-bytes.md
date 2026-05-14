---
template: diagram
duration: 30
transition: fade
---

<div style="left: 5%; top: 8%; width: 90%; text-align: center; font-size: 1.4em;">
  the bootstrap on the wire
  <div style="opacity: 0.7; margin-top: 0.4em;">ブートストラップのバイト列</div>
</div>

<div style="left: 8%; top: 35%; width: 16%; display: flex; flex-direction: column; align-items: center; gap: 0.7rem;">
  <div style="display: flex; gap: 0.3rem;">
    <div style="background: #3498db; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">ESC</div>
    <div style="background: #3498db; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">P</div>
  </div>
  <div style="opacity: 0.8; text-align: center;">
    DCS open
    <div style="opacity: 0.75; margin-top: 0.2em;">開始</div>
  </div>
</div>

<div style="left: 30%; top: 35%; width: 40%; display: flex; flex-direction: column; align-items: center; gap: 0.7rem;">
  <div style="display: flex; gap: 0.3rem;">
    <div style="background: #e67e22; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">+</div>
    <div style="background: #e67e22; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">H</div>
    <div style="background: #e67e22; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">r</div>
    <div style="background: #e67e22; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">a</div>
    <div style="background: #e67e22; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">w</div>
  </div>
  <div style="opacity: 0.8; text-align: center;">
    HTTY payload
    <div style="opacity: 0.75; margin-top: 0.2em;">HTTYペイロード</div>
  </div>
</div>

<div style="left: 76%; top: 35%; width: 16%; display: flex; flex-direction: column; align-items: center; gap: 0.7rem;">
  <div style="display: flex; gap: 0.3rem;">
    <div style="background: #3498db; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">ESC</div>
    <div style="background: #3498db; color: white; padding: 0.5em 0.7em; border-radius: 4px; font-family: monospace; font-weight: bold; min-width: 1.4em; text-align: center;">\</div>
  </div>
  <div style="opacity: 0.8; text-align: center;">
    DCS close
    <div style="opacity: 0.75; margin-top: 0.2em;">終了</div>
  </div>
</div>

<div style="left: 5%; top: 78%; width: 90%; text-align: center; opacity: 0.85;">
  nine bytes total. then: raw HTTP/2.
  <div style="opacity: 0.7; margin-top: 0.4em;">合計9バイト。あとは素のHTTP/2。</div>
</div>

---

Here is the actual bootstrap on the wire. Nine bytes.

The first two — `ESC P` — open a Device Control String. Terminals already know how to consume DCS sequences without rendering them.

The middle five are the payload. `+H` identifies this specifically as HTTY. `raw` is the operation we are asking for.

And the last two — `ESC` backslash — close the DCS.

That is the entire HTTY-specific envelope. After these nine bytes, it is just raw HTTP/2.
