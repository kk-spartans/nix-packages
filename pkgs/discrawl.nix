{ pkgs }:
let
  go = pkgs.go_1_27.overrideAttrs (
    finalAttrs: _: {
      version = "1.27.3";
      src = pkgs.fetchurl {
        url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
        hash = "sha256-bndJA1zzYPBrJXXRYup535/ajvZxiJ5cN1+OUHd/Jrs=";
      };
    }
  );
in
(pkgs.buildGoModule.override { inherit go; }) rec {
  pname = "discrawl";
  version = "0.17.0-unstable-2026-10-24";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "463479029f1ba5f3fed24f49275b4565dc5b8599";
    hash = "sha256-bQGC8/FBoqpPj0w1GVyHnglKMgKTSo2JK6h5b8VlJMY=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-7fdmXYzM2DHeKsiUxJ8BCRxbY/LF/3Jp8lbtXO+EPzg=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
