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
  version = "0.17.0-unstable-2026-10-26";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "38beffa1bd798db78ade91ae76e3c91e4a9ac489";
    hash = "sha256-ISfEiBew/cOBxrVvG+vV65N/RspYJ8+clcdgO8M5iSo=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-u5Ba2XSrYOYk/XSDm1HNRVjO6OHyncGhwoal6bY00IE=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
