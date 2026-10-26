{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.0-unstable-2026-10-26";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "16dfdd825e55f589b30f4410f2ae25e24d2b322e";
    hash = "sha256-kffE6BQuIGSBmx3ITuWXsH+R/CxVBIfMjeCDw9U46mY=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-pvmn4tRoom5Y9z8w6bY9YaEbEybae4cjBrdB20qF8/Q=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
