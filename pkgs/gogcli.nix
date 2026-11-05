{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.1-unstable-2026-11-05";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "efa67af399269df81defffa3be8642714281fc84";
    hash = "sha256-iIz6DqeeWBMMfa3QfJa+Wtm8c7ZvtXaPfD2YIp0iLk0=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-4hP6LV8A3P5G+37gAmFI8dREWauXuLMFjeFjkjon4ms=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
