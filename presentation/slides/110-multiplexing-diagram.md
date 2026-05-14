---
template: diagram
duration: 13
transition: fade
---

<div style="left: 5%; top: 10%; width: 90%; text-align: center; font-size: 1.4em;">
  one pipe, many streams
  <div style="opacity: 0.7; margin-top: 0.4em;">1本のパイプ、複数のストリーム</div>
</div>

<div style="left: 5%; top: 40%; width: 90%; height: 20%; border: 2px solid var(--surface-light); border-radius: 12px; padding: 0.5rem; box-sizing: border-box;">
  <div style="position: relative; display: flex; gap: 0.4rem; height: 100%;">
    <div style="flex: 1; background: #e74c3c; color: white; display: flex; align-items: center; justify-content: center; border-radius: 4px; font-weight: bold;">A</div>
    <div style="flex: 1; background: #3498db; color: white; display: flex; align-items: center; justify-content: center; border-radius: 4px; font-weight: bold;">B</div>
    <div style="flex: 1; background: #e74c3c; color: white; display: flex; align-items: center; justify-content: center; border-radius: 4px; font-weight: bold;">A</div>
    <div style="flex: 1; background: #2ecc71; color: white; display: flex; align-items: center; justify-content: center; border-radius: 4px; font-weight: bold;">C</div>
    <div style="flex: 1; background: #3498db; color: white; display: flex; align-items: center; justify-content: center; border-radius: 4px; font-weight: bold;">B</div>
    <div style="flex: 1; background: #e74c3c; color: white; display: flex; align-items: center; justify-content: center; border-radius: 4px; font-weight: bold;">A</div>
    <div style="flex: 1; background: #2ecc71; color: white; display: flex; align-items: center; justify-content: center; border-radius: 4px; font-weight: bold;">C</div>
    <div style="flex: 1; background: #3498db; color: white; display: flex; align-items: center; justify-content: center; border-radius: 4px; font-weight: bold;">B</div>
  </div>
</div>

<div style="left: 5%; top: 70%; width: 90%; text-align: center; opacity: 0.8;">
  three logical streams (A, B, C) sharing one TCP connection
  <div style="opacity: 0.7; margin-top: 0.4em;">3つの論理ストリーム（A・B・C）が1つのTCP接続を共有</div>
</div>

---

In a diagram: three logical streams — call them A, B, and C — chopped into frames, all interleaved on a single connection.

The receiver joins them back again. That is the whole multiplexing story.
