{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.25.0-unstable-2026-10-26";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "e78aee908bc291aaee2212cdfde82235df1cd74f";
    hash = "sha256-Ys/Cc8AU30iDjbia5IjWQUdEvNnOFsneJXypaWscbJ8=";
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
