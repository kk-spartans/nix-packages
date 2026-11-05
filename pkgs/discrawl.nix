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
  version = "0.19.0-unstable-2026-11-05";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "16a7d41b2fb03dedcad9b6a515a722c091bdc3d1";
    hash = "sha256-rdEL4izBIezwXufviUUBiPCDRNpIvTjh4MU6hKHz8U0=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-5XCj42splxtFhSXGnbkn/G2i1pwwJ1Vzd0gybiG91pA=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
