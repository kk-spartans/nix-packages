{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.1-unstable-2026-11-04";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "dc6bf1f3bba83da3e90b2c67a28fd8422021d5b1";
    hash = "sha256-Ly+4tYjFN7PpqnNn/fAeAbc+R/8j75jNuoKcirof6Kc=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-DESZMHxLfhPPjHruEXd2glJWjAlUR2rHEfyyV+N1q/A=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
