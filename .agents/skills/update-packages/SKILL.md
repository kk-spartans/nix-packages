---
name: update-packages
description: Update all custom nix-packages to latest versions. Handles Go (vendorHash), Rust (cargoHash), npm (npmDepsHash), Python uv FOD (outputHash), fetchurl/fetchzip, and t3-nightly (npm nightly) with harness wrappers. Use when bumping versions, refreshing hashes, or syncing t3-lock.
---

# Update nix-packages

This skill updates every package in `pkgs/` to its latest upstream version. The repo uses `github:nixos/nixpkgs?ref=master` as base; overlays and packages are exposed via `flake.nix:overlays.default` and `flake.nix:packages`.

## Quick inventory (read before updating)

Run these first to see current state:

```bash
ls pkgs/*.nix
cat flake.nix
cat pkgs/t3-nightly-unwrapped.nix  # buildNpmPackage + t3-lock
cat t3-lock/package.json
```

Package types:

| File | Builder | Source | Hashes to update |
|------|---------|--------|------------------|
| `spogo.nix`, `wacli.nix`, `gogcli.nix` | `buildGoModule` | `fetchFromGitHub` `rev` | `hash` (src), `vendorHash` |
| `discrawl.nix` | `buildGoModule` + `go_1_26_4` override | `fetchFromGitHub` | `hash`, `vendorHash`, also `go` version/src hash |
| `tokscale.nix`, `agent-browser-bin.nix` | `rustPlatform.buildRustPackage` | `fetchurl` tarball | `hash` (src), `cargoHash` |
| `fkill.nix` | `stdenv.mkDerivation` FOD | `fetchurl` npm tarball | `hash` (src), `outputHash` (recursive) |
| `hf.nix`, `ocrmypdf.nix` | `stdenv.mkDerivation` FOD (`uv`) | `uv pip install` | `version`, `outputHash` (update `uv pip install` line too) |
| `pixie-sddm.nix`, `aw-watcher-lastfm.nix` | `stdenv{NoCC}.mkDerivation` | `fetchFromGitHub`/`fetchzip` | `rev`/`hash` |
| `t3-nightly-unwrapped.nix` | `buildNpmPackage` | `../t3-lock` (npm) | `version`, `npmDepsHash`, plus `t3-lock` files |
| `bun-baseline.nix` | overlay `final: prev:` | `fetchurl` bun baseline zip | `hash` (src), `version` is inherited from `prev.bun.version` – only hash usually needs update |
| `t3-nightly.nix` | `symlinkJoin` wrapper | `t3-nightly-unwrapped` | no independent version – inherits from unwrapped; only update if harness list changes |

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

## Per-package update steps

### 1. Go (`spogo`, `wacli`, `gogcli`, `discrawl`)

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

### 2. Rust (`tokscale`, `agent-browser-bin`)

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

### 3. npm tarball FOD (`fkill`)

```bash
npm view fkill-cli version   # or `npm view fkill-cli dist-tags`
# update pkgs/fkill.nix: version, hash (fetchurl), outputHash
nix build .#fkill --no-link 2>&1 | tail -n 20  # first gives outputHash got:
```

The `fkill.nix` uses `outputHashMode = "recursive"` with `bun install` + `outputHash`. Set `outputHash = lib.fakeHash` equivalent placeholder `sha256-AAAAAAAA...`, build to get real.

### 4. Python uv FOD (`hf`, `ocrmypdf`)

```bash
# check pypi
curl -s https://pypi.org/pypi/huggingface-hub/json | jq -r '.info.version'
# update pkgs/hf.nix: version, and the `uv pip install huggingface-hub==<version>` line, and outputHash
# same for ocrmypdf (currently outputHash is placeholder `FOOtTBB...` – replace after build)

nix build .#hf --no-link 2>&1 | tail -n 20
# fix outputHash, rebuild
```

These are FODs (`dontUnpack = true`, `outputHashMode = "recursive"`). They vendor via `uv` at build time – network allowed because `outputHash` is set.

### 5. fetchFromGitHub / fetchzip (`pixie-sddm`, `aw-watcher-lastfm`)

```bash
gh api repos/xCaptaiN09/pixie-sddm/commits --jq '.[0].sha'
# update rev + hash in pkgs/pixie-sddm.nix
nix build .#pixie-sddm --no-link
# similarly for aw-watcher-lastfm: check https://github.com/0xbrayo/aw-watcher-lastfm/releases/latest
```

### 6. `t3-nightly` (npm nightly, the most involved)

Current version pinned in `pkgs/t3-nightly-unwrapped.nix:version` and `t3-lock/package.json`. Steps:

```bash
# 1. get latest nightly
npm view t3 dist-tags --json  # look at "nightly"
npm view t3@nightly version
# e.g. 0.0.34-nightly.20260825.1185

# 2. update t3-lock/package.json
jq --arg v "$(npm view t3@nightly version)" '.dependencies.t3 = $v' t3-lock/package.json > /tmp/pkg.json && mv /tmp/pkg.json t3-lock/package.json

# 3. regenerate lockfile (outside Nix, needs npm)
npm --prefix t3-lock install --package-lock-only

# 4. update pkgs/t3-nightly-unwrapped.nix version to match
#    edit `version = "0.0.34-nightly...."`

# 5. refresh npmDepsHash
# set npmDepsHash = lib.fakeHash, then:
nix build .#t3-nightly-unwrapped --no-link 2>&1 | grep "got:"
# copy sha256-... into npmDepsHash

# 6. verify
nix build .#t3-nightly-unwrapped --no-link --print-out-paths
nix build .#t3-nightly --no-link
./result/bin/t3 --version  # should match nightly
```

`pkgs/t3-nightly.nix` rarely needs version change – it inherits from unwrapped. Only update if harness list changes (new `enable*` flags).

### 7. `bun-baseline` overlay

```bash
# check nixpkgs bun version
nix eval github:nixos/nixpkgs/master#bun.version --raw
# overlay in pkgs/bun-baseline.nix overrides src for x86_64 baseline
# update hash:
nix store prefetch-file --json https://github.com/oven-sh/bun/releases/download/bun-v$(nix eval --raw github:nixos/nixpkgs/master#bun.version)/bun-linux-x64-baseline.zip
# put sha256-... into pkgs/bun-baseline.nix
```

## Flake and overlays

After any `pkgs/*.nix` change:

```bash
git add pkgs/<pkg>.nix t3-lock/* flake.nix   # if flake.nix overlay list changed
nix flake check --no-build 2>&1 | head -n 100
nix build .#<pkg> --no-link   # sanity
```

`flake.nix` only needs editing when adding/removing a package (add to `overlays.default` and `packages` set). Otherwise just bump the file.

## Commit / push

```bash
git add pkgs/*.nix t3-lock/ flake.nix .agents/skills/update-packages/SKILL.md
git commit -m "chore: bump <pkg> to <version> (update <hash> + <vendorHash|cargoHash|npmDepsHash|outputHash>)"
git push origin main
# no need to update /etc/nixos flake.lock – skill is internal-only per request
```

## Pitfalls

- FODs (`fkill`, `hf`, `ocrmypdf`, `t3-nightly-unwrapped` via `buildNpmPackage`'s `fetchNpmDeps`) must have `outputHash`/`npmDepsHash` updated via fakeHash workflow; they are allowed network at build time only because hash is fixed.
- Go `vendorHash` changes on any dep bump – always refresh after `rev` change.
- Rust `cargoHash` changes on `Cargo.lock` change.
- `t3-lock` must be committed – `buildNpmPackage` uses `src = ../t3-lock`; if lockfile is stale, `npmDepsHash` will mismatch.
- `ocrmypdf` currently has placeholder outputHash `FOOtTBB...` – needs real hash after next build.
- For `nixpkgs` master, `isLinux`/`isDarwin` deprecations warn – prefer `stdenv.hostPlatform.isLinux`.

## Verify latest nightly (as of skill write)

```bash
npm view t3 dist-tags --json
# {"alpha":"0.0.2","latest":"0.0.33","nightly":"0.0.34-nightly.20260825.1185"}
```

This skill was authored 2026-08-25 – re-check `npm view t3@nightly` for newer nightly before using.
