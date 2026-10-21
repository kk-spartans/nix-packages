# Custom nix packages

Packages I made when there is no official nixpkgs package, or it's really outdated and uses a stack I don't like.

## Updates

`.github/workflows/update-packages.yml` runs every 6 hours: it bumps the nixpkgs input, updates **every** package, commits directly to `main`, and pushes.

- GitHub-backed Go packages (`spogo`, `wacli`, `gogcli`, `discrawl`) follow the default branch head (`--version branch`), not release tags.
- GitHub tag/release tarballs (`tokscale`, `agent-browser`, `aw-watcher-lastfm`, `terminal-browser`, `t3-unwrapped`, `t3-nightly-unwrapped`) are bumped from their GitHub releases; `terminal-browser` refreshes both arch hashes.
- npm tarballs (`fkill`, `portless`, `t1code`) and PyPI packages (`hf`, `ocrmypdf`) publish their version + hashes through a `*-deps` fixed-output derivation, which is what `nix-update` targets. `ocrmypdf` regenerates its hashed `pkgs/ocrmypdf-requirements.txt` lock from `pkgs/ocrmypdf.in` first.

The `*-deps` attributes exist only so the updater has a normal derivation to evaluate; the user-facing packages are the launchers next to them.

## Home Manager modules

All of them live under `inputs.nix-packages.homeManagerModules`.

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

### `services.wacli-sync`

`wacli sync --follow` as a restart-always user service.

```nix
imports = [ inputs.nix-packages.homeManagerModules.wacli-sync ];
services.wacli-sync.enable = true;
```

### `programs.agent-browser`

Installs the `agent-browser` CLI and the upstream agent-browser skill from vercel-labs/agent-browser.

```nix
imports = [ inputs.nix-packages.homeManagerModules.agent-browser ];
programs.agent-browser.enable = true;
```

Requires the `agent-skills` home-manager module; the skill is skipped when it is not imported.

### `programs.spogo`, `programs.gogcli`, `programs.wacli`, `programs.t3`, `programs.hf`

Each installs its CLI and optionally generates shell completions via `enableFishIntegration` (`fish`, `bash`, `zsh`, or `null`). Defaults to `fish` when `programs.fish.enable` is set, otherwise `null`.

```nix
imports = [
  inputs.nix-packages.homeManagerModules.spogo
  inputs.nix-packages.homeManagerModules.gogcli
  inputs.nix-packages.homeManagerModules.wacli
  inputs.nix-packages.homeManagerModules.t3
  inputs.nix-packages.homeManagerModules.hf
];

programs.spogo = {
  enable = true;
  enableFishIntegration = "fish";
};
```
