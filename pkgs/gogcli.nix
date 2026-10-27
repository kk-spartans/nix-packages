{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.1-unstable-2026-10-27";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "82e7fd6005d4ed29f8edfa2a44475e08fe3051a0";
    hash = "sha256-D7c24Cc+/RVlhHVV7fM6BDYb/rK9/4PYjPlKLStNacs=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-DESZMHxLfhPPjHruEXd2glJWjAlUR2rHEfyyV+N1q/A=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
