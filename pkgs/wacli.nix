{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.24.0-unstable-2026-10-22";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "c1b600a2cc36c0bf88c4687d5aa3afe56f89c7e3";
    hash = "sha256-Gw1dzguR/6Q6Ninu3snxWfgC6p0fjlYOQV4EHxc1vUs=";
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
