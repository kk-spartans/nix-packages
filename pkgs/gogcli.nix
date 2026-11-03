{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.1-unstable-2026-11-03";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "388bc991107a2661b5ab69d977ea8e6bd3fba46d";
    hash = "sha256-y5QLreSn5UTZumMMqHcxY+Bqt46IvH/UVGz8MvEy89o=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-DESZMHxLfhPPjHruEXd2glJWjAlUR2rHEfyyV+N1q/A=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
