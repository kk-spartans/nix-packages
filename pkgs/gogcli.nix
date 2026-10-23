{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.46.0-unstable-2026-10-23";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "f9052a583e87637894b72199b9dc2b47cfa7f37a";
    hash = "sha256-igKafkCAEumVqNLrvpERGpCypo3kcDFtHjUPZGWlQBw=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-pvmn4tRoom5Y9z8w6bY9YaEbEybae4cjBrdB20qF8/Q=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
