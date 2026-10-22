{ pkgs }:
pkgs.buildGoModule rec {
  pname = "spogo";
  version = "0.13.2-unstable-2026-10-22";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "spogo";
    rev = "61001a475be735fcfbdb5f96448bd3988caad31c";
    hash = "sha256-BJ1bAG6XUbPo8bOZk1pWZeOK73jJxXLLfEWAicQrn28=";
  };

  subPackages = [ "cmd/spogo" ];
  vendorHash = "sha256-Ivwxg+uq8fsC0FodGWKyMEBP1AyrIcbI6UmgvAsSQ9g=";

  # Upstream defaults `version` to "dev"; without this `--version` prints
  # "dev" regardless of the pinned rev.
  ldflags = [ "-X github.com/steipete/spogo/internal/cli.version=${version}" ];

  meta.mainProgram = "spogo";
}
