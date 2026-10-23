{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.46.0-unstable-2026-10-23";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "f7dab31f4249cb4f275dff81e2f840d6c626bf39";
    hash = "sha256-IQq1fOEtPWaGVCoYiKEfhNUz5kaGgOjAr/7GwiGZnlg=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-pvmn4tRoom5Y9z8w6bY9YaEbEybae4cjBrdB20qF8/Q=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
