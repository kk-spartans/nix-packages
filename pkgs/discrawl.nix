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
    rev = "4800365f5245c8c93bf3ecf17c571faf987a1cac";
    hash = "sha256-k0NI+bQNVeLgor6ZgP82EARvALpwLzOQfyeQS51QoMk=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-5XCj42splxtFhSXGnbkn/G2i1pwwJ1Vzd0gybiG91pA=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
