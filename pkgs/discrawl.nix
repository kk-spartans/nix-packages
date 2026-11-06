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
  version = "0.20.0-unstable-2026-11-06";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "f93da5003e30450044983f190bfc638989f3c7f3";
    hash = "sha256-QxHXuShWmxfhgwsahHf0ZD410XKsAph4x5gNm+7k3xE=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-mbcdWmJxXu2ALEgimRmqdYLYiYqUcweFicVDRR5wnf4=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [
    "-X github.com/openclaw/discrawl/internal/cli.version=${version}"
  ];
}
