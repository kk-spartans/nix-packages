{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.1-unstable-2026-10-27";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "b8298ae6fd5335ddebc4bc8594e3b09aa3020ab4";
    hash = "sha256-MaJNb5s6D+prVu8OH9jPylW6bhC9ausZxpuGypQparU=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-YPNJB9PUesnwEPUQt5RO1dmJzBoU+MQQMUEtSd06/vY=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
