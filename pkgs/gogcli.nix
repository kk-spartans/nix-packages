{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.48.0-unstable-2026-11-05";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "e8428c36dd31db13eecba55fcef6f4ee75951188";
    hash = "sha256-eLpKgD8nsu3dOFDrl3hQ8AOer3q0UKon6VhR1NXM0GE=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-4hP6LV8A3P5G+37gAmFI8dREWauXuLMFjeFjkjon4ms=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
