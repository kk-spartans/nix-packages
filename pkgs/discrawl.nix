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
  version = "0.16.0-unstable-2026-10-21";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "6d670fc461f47be414b3c2a24e041657820195aa";
    hash = "sha256-zixX5snqDEv5Noj5/GIvJ6qvYtfPnPk9IPH/4ZLANWo=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-AiWEkdwkfaox3IGAq99hNDpxTZ3S6c/CGEbbdTnDX8I=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
