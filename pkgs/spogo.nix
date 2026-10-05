{ pkgs }:
pkgs.buildGoModule {
  pname = "spogo";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "spogo";
    rev = "bebab026d646f77d3a660c849ffe5fdb8e34e956";
    hash = "sha256-Kl7bDE1ujCqpH5bIJmzuI6RkcSZcSq4x/AkIsIH5Dlg=";
  };

  subPackages = [ "cmd/spogo" ];
  vendorHash = "sha256-Ivwxg+uq8fsC0FodGWKyMEBP1AyrIcbI6UmgvAsSQ9g=";
}
