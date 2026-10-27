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
  version = "0.18.0-unstable-2026-10-27";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "4e35a0f9bb8d5f27d6afe604eb769e90521dbf2e";
    hash = "sha256-SZ5BYrjuG40bDOxsPhL3DnFX4OTs+azMcGGGtNJpRbs=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-u5Ba2XSrYOYk/XSDm1HNRVjO6OHyncGhwoal6bY00IE=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
