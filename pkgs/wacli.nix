{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.25.1-unstable-2026-11-05";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "616b348a0c74e96ef325016ae9db4894527c120f";
    hash = "sha256-z4qGcU4KpPgtzDvD7NMG+mGpcMHOiwKSy4y5czNyp6E=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-PsKqI3zzNw5e38DSfa/qjorfjFsTxTRzNcw/EH4L9rk=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';

  meta.mainProgram = "wacli";
}
