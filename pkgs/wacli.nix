{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.26.0-unstable-2026-11-05";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "535a8b969cc83c3aad57f66be77e8fd4a7fcaaa3";
    hash = "sha256-CVjttZfkV1kIHxZTmWSJL3h4Zt/+c7A11LIJBrQu8kc=";
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
