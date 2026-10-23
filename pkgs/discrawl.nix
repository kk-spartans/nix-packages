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
  version = "0.16.0-unstable-2026-10-23";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "dcca8a4c399ad6d33092566e031e7a95ad259956";
    hash = "sha256-Lb1r7Ze8tbnBABPOWvIZT9Mu7mSL7kVuhngObYLvrHk=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-AiWEkdwkfaox3IGAq99hNDpxTZ3S6c/CGEbbdTnDX8I=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
