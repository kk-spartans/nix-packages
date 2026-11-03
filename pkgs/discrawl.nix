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
  version = "0.19.0-unstable-2026-11-02";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "f6a6ecd916b7cc49fa5bd753649e957238326b38";
    hash = "sha256-/5l3fm81fCgmcNzuFlOcdAx6XhCsxRavjBRKj1U9aDU=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-i+6Hf4DcvGwkWX0TgNNcNrlC4VgbhJAy4GWbTbstKtI=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
