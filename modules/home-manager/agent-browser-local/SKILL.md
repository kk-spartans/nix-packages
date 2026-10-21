---
name: agent-browser-local
description: Local machine policy for the agent-browser CLI. Applies whenever you drive a browser with agent-browser on this host.
---

# agent-browser local policy (this machine — overrides upstream defaults)

- `agent-browser` on PATH is already wired to the correct persistent
  browser (a per-host wrapper selects it). Do NOT create named sessions:
  never export `AGENT_BROWSER_SESSION`, never run `agent-browser session
  id`, never pass `--session` / `--namespace`.
- Use plain commands (`agent-browser open/click/fill/...`) so work stays
  in the shared visible session the human watches.
- The upstream agent-browser skill's "always use your own session" rule
  does NOT apply here; this policy overrides it.
- Never run `agent-browser close --all`: it may kill the shared
  persistent browser and everyone's tabs along with it. Prefer leaving
  the browser running; close only tabs you opened if you must.
