{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.25.1-unstable-2026-10-27";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "b7603b697e69be591afa83379ced1e73177604c6";
    hash = "sha256-sD85/lIbvrfkEZH8UBLz9g+nug/oPz+m01Tu9XbrImk=";
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
