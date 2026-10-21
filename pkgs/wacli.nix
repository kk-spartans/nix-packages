{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.24.0-unstable-2026-10-21";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "0d54b6b5370cfd256300e4bfb1d51dcf90afeb30";
    hash = "sha256-7Apg6qK8ucfMYa5w/y8Q6NCr5qyZtYpgNknkZNJXzmk=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-Kcbd/If+63q4TRifEH3iZ+Doc5sF10MQLViBhsr0buE=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';
}
