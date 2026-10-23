{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.24.0-unstable-2026-10-23";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "6710b4b6b54696c1b90597f40f4cd747901bd9f7";
    hash = "sha256-5jIFvp71R6eefOpflQJ4dWAqOz2f7HYqgt3bPEN3JVE=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-Kcbd/If+63q4TRifEH3iZ+Doc5sF10MQLViBhsr0buE=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';

  meta.mainProgram = "wacli";
}
