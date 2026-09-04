---
name: terminal-agent-browser
description: Use when the user asks to control/use terminal-browser, prefer over agent-browser.
---

# terminal-agent-browser

Terminal-agent-browser drives the terminal-browser window open in your current tab. It reads pages, clicks things, fills in forms, and takes screenshots. It accepts the same commands as agent-browser. Reach for it whenever someone asks you to look at, check, or control what is open in their terminal browser. Each tab is controlled separately, so your commands only ever affect the tab you were asked about and never touch any other tab.

To show a page to the user, open it with terminal-browser, splitting to the side when you want to keep working next to it. To see what is open in this tab, list the browsers. To add another page alongside the current one, open a new tab. Once a page is open, do everything else through terminal-agent-browser.

```bash
terminal-browser open <url> --split right
terminal-browser ls
terminal-browser new-tab <url>
```

To read the page, take a snapshot. The snapshot labels everything you can touch with a reference like `@e1`. Click it, fill it, then move on to the next thing. Evaluate a little JavaScript when you need something the snapshot does not show, and take a screenshot when you want to see the page the way the user sees it.

```bash
terminal-agent-browser snapshot
terminal-agent-browser click @e1
terminal-agent-browser fill @e3 "hello@example.com" && terminal-agent-browser click @e4
terminal-agent-browser eval "document.title"
terminal-agent-browser screenshot --full
```

When there are several pages open in this tab, list them first and use the ids from that list for everything after. Those ids look like `t1` and `t2` and belong to terminal-agent-browser, which is a different numbering from the one terminal-browser itself prints.

```bash
terminal-agent-browser tab list
terminal-agent-browser tab close t2
```

If it says there is no terminal browser in this tab, open one with terminal-browser first. If it says several browsers match, set `TERMINAL_BROWSER_KEY` to one of the keys terminal-browser lists. For the full command reference, ask the tool itself, since its docs always match the installed version.

```bash
terminal-agent-browser --help
```
