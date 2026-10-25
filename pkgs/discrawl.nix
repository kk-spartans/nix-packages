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
  version = "0.17.0-unstable-2026-10-25";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "df69b29f0c76929e419e4f29020234a568e9285d";
    hash = "sha256-REbWrMXyC+6DUSRGJoexv1HrVP4vN630zHSMH9liiLo=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-u5Ba2XSrYOYk/XSDm1HNRVjO6OHyncGhwoal6bY00IE=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
