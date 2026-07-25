{ pkgs }:
pkgs.buildGoModule {
  pname = "spogo";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "spogo";
    rev = "80d18f28f44a0d0777b62c1317d9855cb3ffb8a9";
    hash = "sha256-ItC3ZK3U1e1FrSi0ildiYyWVYwTAiT7xUQrZ6GmvrKg=";
  };

  subPackages = [ "cmd/spogo" ];
  vendorHash = "sha256-aUMu71ZIjM+87vneKNRXuaFZCW5IB5d2jAey/1itqYM=";
}
