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
  version = "0.19.0-unstable-2026-10-30";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "b095420d39186068c0eddfb8bb597b42a60d7f2e";
    hash = "sha256-5P0tJpBRH1S8M4dx6bM8Ry5ix0Ffb5Op846bbaxYrD4=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-i+6Hf4DcvGwkWX0TgNNcNrlC4VgbhJAy4GWbTbstKtI=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
