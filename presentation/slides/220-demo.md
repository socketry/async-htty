---
template: statement
duration: 60
transition: fade
---

demo

# Translation

デモ

---

*Switch to terminal. Leave this slide up as the audience's anchor.*

Demo plan (~2 min). **Primary path: SSH**, if the network is up.

```bash
$ ssh <host>
remote$ ruby async-htty/examples/hello_world.rb
```

Then attach with Chimera *locally* and show the response coming back in the browser pane. Say it out loud: "this program is running on `<host>`, not on my laptop — same protocol, no extra plumbing."

**Fallback path: local**, if the network is dead.

```bash
$ cd async-htty
$ ruby examples/hello_world.rb
```

Either way: if the basic example works, swap to `examples/browser_demo.rb` to show HTML rendering. If anything goes wrong mid-demo, narrate it — the audience cares more about seeing the moment of takeover than a polished run.
