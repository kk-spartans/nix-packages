---
name: update-packages
description: Update all custom nix-packages to latest versions. Edit when user asks to add a new package, always keep this skill updated with the current repo state.
---

# Update nix-packages

This skill updates **every** package in `pkgs/` to its latest upstream version — not just the ones listed here. When a new package is added (e.g. `terminal-browser`), infer its update method from its builder/source rather than waiting for this doc to mention it.

The repo uses `github:nixos/nixpkgs?ref=master` as base; overlays and packages are exposed via `flake.nix:overlays.default` and `flake.nix:packages`.

## 0. Discover — do this first, every time

Don't trust the package list below as exhaustive. Enumerate what's actually on disk:

```bash
ls -1 pkgs/*.nix
cat flake.nix
# for each pkgs/<name>.nix: note builder, fetcher, and version source
grep -l "buildGoModule\|buildRustPackage\|buildNpmPackage\|mkDerivation\|fetchFromGitHub\|fetchurl\|fetchzip" pkgs/*.nix
```

For each file, read it fully and classify:

| Signals in the .nix | Type | How to find latest | What to bump |
|---|---|---|---|
| `buildGoModule` + `fetchFromGitHub` `rev` | Go | `gh api repos/<owner>/<repo>/commits --jq '.[0].sha'` or tags | `rev`, `hash`, `vendorHash` |
| `buildGoModule` + `go.overrideAttrs` | Go with pinned toolchain | same + `https://go.dev/dl/?mode=json` | above + `go` `version`/`hash` |
| `rustPlatform.buildRustPackage` + `fetchurl` | Rust | `curl -s https://api.github.com/repos/<owner>/<repo>/tags \| jq -r '.[0].name'` | `version`, `hash`, `cargoHash` |
| `stdenv.mkDerivation` + `fetchurl` + `outputHashMode = "recursive"` | FOD tarball (npm/bun) | `npm view <pkg> version` | `version`, `hash`, `outputHash` |
| `stdenv.mkDerivation` + `uv pip install` + `outputHashMode` | Python uv FOD | `curl -s https://pypi.org/pypi/<name>/json \| jq -r '.info.version'` | `version`, `outputHash`, and the `uv pip install <name>==<version>` line |
| `stdenv*mkDerivation` + `fetchFromGitHub`/`fetchzip` (no FOD) | Plain fetch | `gh api repos/<owner>/<repo>/commits` or `/releases/latest` | `rev`/`version`, `hash` |
| `buildNpmPackage` + `src = ../<lock-dir>` | npm lockfile package | `npm view <pkg> dist-tags --json` | `version`, `npmDepsHash`, plus lock dir files |
| `final: prev:` overlay | Nixpkgs overlay | `nix eval github:nixos/nixpkgs/master#<attr>.version --raw` + upstream release | `hash` (version is inherited) |
| `symlinkJoin` wrapper | Wrapper | inherits from unwrapped | only if harness/wrapper logic changes |
| `stdenv.mkDerivation` + binary `fetchurl` + `autoPatchelfHook` | Binary tarball (e.g. `terminal-browser` from `zenbu-labs/terminal-browser`) | `gh api repos/zenbu-labs/terminal-browser/releases --jq '.[0].tag_name'` or `gh release view --repo zenbu-labs/terminal-browser` | `version`, `hash` per-platform |

If a package doesn't match any row, read its `src` fetcher and builder and apply the **General hash workflow** below — that covers any future package.

## Quick inventory (read before updating)

```bash
ls pkgs/*.nix
cat flake.nix
cat pkgs/t3-unwrapped.nix pkgs/t3.nix pkgs/t3-nightly.nix  # t3: GitHub release archive
```

Known package types (non-exhaustive — see discovery table above):

| File | Builder | Source | Hashes to update |
|------|---------|--------|------------------|
| `spogo.nix`, `wacli.nix`, `gogcli.nix` | `buildGoModule` | `fetchFromGitHub` `rev` | `hash` (src), `vendorHash` |
| `discrawl.nix` | `buildGoModule` + `go_1_26_4` override | `fetchFromGitHub` | `hash`, `vendorHash`, also `go` version/src hash |
| `tokscale.nix`, `agent-browser-bin.nix` | `rustPlatform.buildRustPackage` | `fetchurl` tarball | `hash` (src), `cargoHash` |
| `fkill.nix` | `stdenv.mkDerivation` FOD | `fetchurl` npm tarball | `hash` (src), `outputHash` (recursive) |
| `hf.nix`, `ocrmypdf.nix` | `stdenv.mkDerivation` FOD (`uv`) | `uv pip install` | `version`, `outputHash` (update `uv pip install` line too) |
| `discord-cli.nix` | two-phase `uv`: deps FOD (`uv pip install --target`, `rm -rf $out/bin`) + plain launcher drv | PyPI `kabi-discord-cli` | `version`, `outputHash` of the inner `deps` FOD |
| `pixie-sddm.nix`, `aw-watcher-lastfm.nix` | `stdenv{NoCC}.mkDerivation` | `fetchFromGitHub`/`fetchzip` | `rev`/`hash` |
| `terminal-browser.nix` | `stdenv.mkDerivation` + `autoPatchelfHook` | `fetchurl` per-arch tarball from `github:zenbu-labs/terminal-browser` releases | `version`, `hash` per-arch |
| `t3-unwrapped.nix` | `stdenv.mkDerivation` (Node SEA binary) | `fetchurl` of the `t3-<version>-linux-x64.tar.gz` GitHub release asset | `version` + `hash` (passed in by the wrapper) |
| `t3.nix` | generic `symlinkJoin` wrapper + harness `enable*` flags | `t3-unwrapped` | stable pins `t3Version`/`t3Hash` defaults; wrapper logic only when harness list changes |
| `t3-nightly.nix` | thin `callPackage ./t3.nix { ... }` | `t3.nix` | `t3Version` + `t3Hash` |

## General hash workflow

For any hash, set it to `lib.fakeHash` (or placeholder), run build, copy "got: sha256-..." from error:

```bash
# example
nix build .#<pkg> --no-link 2>&1 | grep -A2 "got:"
# or for flake
nix build /home/kk-spartans/nix-packages#<pkg> --no-link 2>&1 | tail -n 20
```

For `fetchFromGitHub` you can also use `nix-prefetch-github` or:

```bash
nix store prefetch-file --json https://github.com/<owner>/<repo>/archive/<tag>.tar.gz
nix-prefetch-url --unpack https://github.com/<owner>/<repo>/archive/<tag>.tar.gz  # gives SRI for fetchzip/fetchFromGitHub (convert with `nix hash convert`)
```

> **Hash-type trap (burned twice):** `--unpack` hashes the *unpacked tree* and only
> matches `fetchzip` / `fetchFromGitHub`. A plain `fetchurl` of a `.tar.gz`
> (Rust crates, release archives, npm tarballs) needs the **file** hash — drop
> `--unpack`:
>
> ```bash
> nix store prefetch-file --json <url>              # fetchurl
> nix store prefetch-file --json --unpack <url>     # fetchzip / fetchFromGitHub
> ```
>
> Symptom when you get it wrong: the build fails with
> `specified: sha256-X / got: sha256-Y` where `got` differs from what you
> prefetched. Re-prefetch without `--unpack` instead of trusting the first value.

For per-arch binary tarballs (like `terminal-browser` from `zenbu-labs/terminal-browser`):

```bash
# github releases — also where the SRI digest is shown in gh api output
gh api repos/zenbu-labs/terminal-browser/releases/tags/v<version> --jq '.assets[] | "\(.name) \(.browser_download_url) \(.digest)"'
nix store prefetch-file --json https://github.com/zenbu-labs/terminal-browser/releases/download/v<version>/terminal-browser-linux-x64.tar.gz
nix store prefetch-file --json https://github.com/zenbu-labs/terminal-browser/releases/download/v<version>/terminal-browser-linux-arm64.tar.gz
# or: gh release view v<version> --repo zenbu-labs/terminal-browser --json assets --jq '.assets[] | .url'
```

## Per-package update steps

### 1. Go (`spogo`, `wacli`, `gogcli`, `discrawl` — and any future Go package)

```bash
# get latest commit/tag
gh api repos/openclaw/spogo/commits --jq '.[0].sha' # or `gh release view` / `git ls-remote`
# or for tags: curl -s https://api.github.com/repos/openclaw/spogo/tags | jq -r '.[0].name'

# update pkgs/spogo.nix:
# - rev = "<new-sha>"
# - hash = "sha256-..."  # set fakeHash, build, copy
# - vendorHash = "sha256-..." # same

nix build .#spogo --no-link 2>&1 | tail -n 20
# fix hash, rebuild, then also:
nix build .#spogo --no-link && echo ok
```

`discrawl.nix` additionally pins `go_1_26_4` – check `https://go.dev/dl/` for latest, update `version` and `hash` inside the `go.overrideAttrs` block if bumping Go.

### 2. Rust (`tokscale`, `agent-browser-bin` — and any future Rust package)

```bash
# latest tag
curl -s https://api.github.com/repos/junhoyeo/tokscale/tags | jq -r '.[0].name'
# or for agent-browser: vercel-labs/agent-browser

# update pkgs/tokscale.nix:
# version = "x.y.z"
# hash = "sha256-..."  # fetchurl hash
# cargoHash = "sha256-..." # set fakeHash, build

nix build .#tokscale --no-link 2>&1 | tail -n 20
```

### 3. npm tarball FOD (`fkill` — and any similar FOD)

```bash
npm view fkill-cli version   # or `npm view fkill-cli dist-tags`
# update pkgs/fkill.nix: version, hash (fetchurl), outputHash
nix build .#fkill --no-link 2>&1 | tail -n 20  # first gives outputHash got:
```

The `fkill.nix` uses `outputHashMode = "recursive"` with `bun install` + `outputHash`. Set `outputHash = lib.fakeHash` equivalent placeholder `sha256-AAAAAAAA...`, build to get real.

### 4. Python uv FOD (`hf`, `ocrmypdf` — and any future uv FOD)

```bash
# check pypi
curl -s https://pypi.org/pypi/huggingface-hub/json | jq -r '.info.version'
# update pkgs/hf.nix: version, and the `uv pip install huggingface-hub==<version>` line, and outputHash
# same for ocrmypdf

nix build .#hf --no-link 2>&1 | tail -n 20
# fix outputHash, rebuild
```

These are FODs (`dontUnpack = true`, `outputHashMode = "recursive"`). They vendor via `uv` at build time – network allowed because `outputHash` is set.

### 5. fetchFromGitHub / fetchzip (`pixie-sddm`, `aw-watcher-lastfm` — and any plain fetch)

```bash
gh api repos/xCaptaiN09/pixie-sddm/commits --jq '.[0].sha'
# update rev + hash in pkgs/pixie-sddm.nix
nix build .#pixie-sddm --no-link
# similarly for aw-watcher-lastfm: check https://github.com/0xbrayo/aw-watcher-lastfm/releases/latest
```

### 6. Binary tarball (`terminal-browser` — and any future binary package)

```bash
# terminal-browser lives at github:zenbu-labs/terminal-browser — use gh cli
gh api repos/zenbu-labs/terminal-browser/releases --jq '.[0].tag_name'  # e.g. v0.7.6
gh api repos/zenbu-labs/terminal-browser/releases/tags/v0.7.6 --jq '.assets[] | "\(.name) \(.digest)"'
# or: gh release view --repo zenbu-labs/terminal-browser v0.7.6 --json tagName,assets

# prefetch both arches (github release URLs):
nix store prefetch-file --json https://github.com/zenbu-labs/terminal-browser/releases/download/v<version>/terminal-browser-linux-x64.tar.gz
nix store prefetch-file --json https://github.com/zenbu-labs/terminal-browser/releases/download/v<version>/terminal-browser-linux-arm64.tar.gz
# update pkgs/terminal-browser.nix version + both srcHash branches
nix build .#terminal-browser --no-link 2>&1 | tail -n 20
# for other binary tarballs, adapt: use gh api for github releases, or curl -I probe for direct dl hosts
```

### 7. `t3` / `t3-nightly` (Node SEA release archive)

`t3-unwrapped.nix` is generic: it takes `version` + `hash` and fetches

```
https://github.com/pingdotgg/t3code/releases/download/v<version>/t3-<version>-linux-x64.tar.gz
```

Do **not** go through npm. Since 0.1.x the `t3` npm package is a runtime
downloader, and npm 11 cannot produce a `package-lock.json` that `npm ci`
accepts for the 0.1.x dependency tree (it omits cross-platform optional deps
and then fails its own sync check). The GitHub release archive is the real
artifact: `t3` binary + `node_modules/` + `client/`.

```bash
# stable version lives in pkgs/t3.nix (t3Version/t3Hash defaults),
# nightly in pkgs/t3-nightly.nix.
npm view t3 dist-tags --json   # latest / nightly
gh api repos/pingdotgg/t3code/releases/tags/v<version> --jq '.assets[].name' | grep linux-x64

# hash is the FILE hash (fetchurl, no --unpack):
nix store prefetch-file --json https://github.com/pingdotgg/t3code/releases/download/v<version>/t3-<version>-linux-x64.tar.gz

# update version+hash, then verify — the archive's `t3 --version` must match:
nix build .#t3 --no-link --print-out-paths
nix build .#t3-nightly --no-link --print-out-paths
"$(nix build .#t3-nightly --no-link --print-out-paths | tail -1)/bin/t3" --version
```

Notes:
- `t3-unwrapped.nix` sets `dontStrip = true` and does **not** run
  `autoPatchelfHook`; see the Node SEA pitfall below.
- Stable and nightly share `pkgs/t3.nix` (both expose the harness
  `enable*` flags). `t3-nightly.nix` is a three-line `callPackage` with its
  own pin.
- `t3-unwrapped` must **not** be added to the overlay: `callPackage` would
  auto-supply it and silently override the version-specific default
  (`t3-nightly` would then build the stable binary). Use
  `pkgs.t3.passthru.unwrapped` / `pkgs.t3-nightly.passthru.unwrapped` if you
  need the raw binary.

## Flake and overlays

After any `pkgs/*.nix` change:

```bash
git add pkgs/<pkg>.nix flake.nix   # if flake.nix overlay list changed
nix flake check --no-build 2>&1 | head -n 100
nix build .#<pkg> --no-link   # sanity
```

`flake.nix` only needs editing when adding/removing a package (add to `overlays.default` and `packages` set). Otherwise just bump the file.

For packages gated on `lib.optionalAttrs stdenv.isLinux` (like `terminal-browser`), add them in both `overlays.default` and `packages` inside the `// optionalAttrs isLinux` branch.

## Commit / push

```bash
git add pkgs/*.nix flake.nix .agents/skills/update-packages/SKILL.md
git commit -m "chore: bump <pkg> to <version> (update <hash> + <vendorHash|cargoHash|npmDepsHash|outputHash>)"
git push origin main
# no need to update /etc/nixos flake.lock – skill is internal-only per request
```

## Pitfalls

- **`fetchurl` hash type**: `nix store prefetch-file --unpack` returns the
  *unpacked tree* hash (`fetchzip`/`fetchFromGitHub`). Plain `fetchurl` of a
  tarball needs the file hash — omit `--unpack`. Wrong choice shows up as
  `specified: sha256-X / got: sha256-Y` with a `got` you never prefetched.
- **Node SEA binaries (t3): SIGILL is not a CPU/AVX2 problem.** t3 ships a
  Node single-executable-application: the node executable with the app blob
  appended. Nix's fixup phase strips ELF files by default, which corrupts the
  blob, and the process dies with `Illegal instruction (core dumped)` before
  `main()`. `patchelf` on it is equally fatal. Fix: `dontStrip = true`, no
  `autoPatchelfHook`, and inject runtime libs through the wrapper
  (`--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}`).
  Confirm with `readelf -n <binary>`: no `.note.gnu.property` ISA note means
  the binary requires nothing beyond baseline x86-64, so do not chase AVX2.
- FODs (`fkill`, `hf`, `ocrmypdf`) must have `outputHash` updated via the
  fakeHash workflow; they are allowed network at build time only because the
  hash is fixed.
- FOD `$out` must not contain store references (no venvs, no symlinks to `/nix/store`, no absolute shebangs/scripts) — Nix errors with "fixed-output derivations must not reference store paths", and `$out`-embedding content can never converge since the FOD output path derives from `outputHash`. `discord-cli.nix` pattern: FOD installs to `--target` with `bin/` removed, plain derivation provides the launcher.
- Go `vendorHash` changes on any dep bump – always refresh after `rev` change.
- Rust `cargoHash` changes on `Cargo.lock` change.
- Never re-add `t3-lock/`; the t3 packages fetch the release archive directly.
- For `nixpkgs` master, `isLinux`/`isDarwin` deprecations warn – prefer `stdenv.hostPlatform.isLinux`.
- When a new package is added, update this skill's "Known package types" table and the discovery table if it introduces a new builder/fetcher pattern.

## Verify latest t3 (as of last update: 2026-10-21)

```bash
npm view t3 dist-tags --json
# {"alpha":"0.0.2","latest":"0.1.1","nightly":"0.1.2-nightly.20261021.3457","preview":"0.1.1-preview.20261021.3449"}
gh api repos/pingdotgg/t3code/releases --jq '.[] | .tag_name' | head -5
```

Always confirm a `t3-<version>-linux-x64.tar.gz` asset exists for the version
you pin (nightlies lag their npm publish by a few minutes, and some npm
releases have no platform artifact at all).

This skill was authored 2026-08-25 – re-check the dist-tags and release assets
before bumping.
