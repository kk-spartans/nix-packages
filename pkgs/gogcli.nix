{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.0-unstable-2026-10-23";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "563e30a205d911f7f2bd15f4504ee950e6e98cf2";
    hash = "sha256-VILKKOlZK9G8OEDP7ovsuOW6cpsp5/9HJ0UPwaj2syI=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-pvmn4tRoom5Y9z8w6bY9YaEbEybae4cjBrdB20qF8/Q=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
