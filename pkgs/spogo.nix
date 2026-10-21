{ pkgs }:
pkgs.buildGoModule rec {
  pname = "spogo";
  version = "0.13.2-unstable-2026-10-21";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "spogo";
    rev = "be23d8b2023b100f1b87e4d5672e36a6b72f45bb";
    hash = "sha256-snyUl0isNVn5PenluBOwI+CWeOhK/WGocuiY19f0w2M=";
  };

  subPackages = [ "cmd/spogo" ];
  vendorHash = "sha256-Ivwxg+uq8fsC0FodGWKyMEBP1AyrIcbI6UmgvAsSQ9g=";

  # Upstream defaults `version` to "dev"; without this `--version` prints
  # "dev" regardless of the pinned rev.
  ldflags = [ "-X github.com/steipete/spogo/internal/cli.version=${version}" ];
}
