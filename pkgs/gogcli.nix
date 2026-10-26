{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.0-unstable-2026-10-26";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "1d0d4d230349c2be75f94ab6d6b14027e81ab5ca";
    hash = "sha256-pOJjo3NLUkFPrIOjUcIQJ4lXKfOseQQcPVRFY7pXTE4=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-YPNJB9PUesnwEPUQt5RO1dmJzBoU+MQQMUEtSd06/vY=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
