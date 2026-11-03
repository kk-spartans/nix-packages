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
  version = "0.19.0-unstable-2026-11-03";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "df90e1132a45f24a9a52334f688edf7560fc1274";
    hash = "sha256-uyrm/JnWZnhG5hz6sW1Im7mEGA10w1c0iTwpj0yJN0Q=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-i+6Hf4DcvGwkWX0TgNNcNrlC4VgbhJAy4GWbTbstKtI=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
