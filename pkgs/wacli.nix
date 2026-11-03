{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.25.1-unstable-2026-11-03";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "4a10ee2537bc9e22d5569ec1995804c2a52c772d";
    hash = "sha256-Qc6vPxTFWwSQ3gDdI1T+dO8fkjRkF4/OY8uJ28aPQCg=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-u8QUTk3hNqMp0mvjq0NpEZzaRZwtqm4mXIE3XMAURsI=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';

  meta.mainProgram = "wacli";
}
