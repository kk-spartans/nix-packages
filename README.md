# Custom nix packages

Packages I made when there is no official nixpkgs package, or it's really outdated and uses a stack I don't like.

## Home Manager modules

### `services.t3-server`

Headless T3 Code server (`t3 serve`) as a systemd user service, with tailscale support.

```nix
# flake input: nix-packages
imports = [ inputs.nix-packages.homeManagerModules.default ];

services.t3-server = {
  enable = true;
  harnesses.enableClaude = true; # extra agent CLIs on PATH (codex/git/gh are on by default)
  tailscale.enable = true;       # wait for tailscaled, expose via `tailscale serve`
};
```

- `tailscale.serve` (default when tailscale is enabled): publishes the server over HTTPS on the tailnet using t3's built-in `--tailscale-serve` flag. Needs your user to be a tailscale operator: `sudo tailscale set --operator <user>`.
- `tailscale.bindIp`: alternative mode that binds straight to the tailnet IPv4 (plain HTTP over WireGuard).
- Pairing URL/token prints once on first start: `journalctl --user -u t3-server`. Mint more with `t3 pair`.
- Survive logout: `sudo loginctl enable-linger <user>`.

### `programs.terminal-agent-browser`

Per-herdr-tab agent control for terminal-browser (`terminal-agent-browser`
wrapper + skill). Agents and terminal-browser panes in the same herdr tab
share one agent-browser session; different tabs are isolated. Never shadows
your own `agent-browser` install, and never downloads Chromium (always drives
terminal-browser's Chromium over CDP).

```nix
# flake input: nix-packages
imports = [ inputs.nix-packages.homeManagerModules.terminal-agent-browser ];

programs.terminal-agent-browser = {
  enable = true;
  skill.enable = true; # install ~/.agents/skills/terminal-agent-browser/SKILL.md
};
```

- Binary: `terminal-agent-browser <agent-browser args>` (e.g. `snapshot`, `click @e1`).
- Open pages with `terminal-browser open`, list with `terminal-browser ls`.
- Overrides: `TERMINAL_AGENT_BROWSER_SESSION`, `TERMINAL_BROWSER_KEY`, `TERMINAL_BROWSER_CDP_PORT`.

