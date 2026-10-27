{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.25.1-unstable-2026-10-27";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "bf7f72e7b30c372e07c2a9ff9acceb087e5e49d5";
    hash = "sha256-HIdmNBUDASXsv1JbPa6hdlyamumnjqpQoSeW7uGUt90=";
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
