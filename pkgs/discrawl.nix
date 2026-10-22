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
  version = "0.16.0-unstable-2026-10-22";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "6d23bc9a928666c01965fd20da6aa25800f3fc85";
    hash = "sha256-a3XXiH8UKLlMK6w2gAdKzA1jdf7x6cHkNK6O/x6vw/s=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-AiWEkdwkfaox3IGAq99hNDpxTZ3S6c/CGEbbdTnDX8I=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
