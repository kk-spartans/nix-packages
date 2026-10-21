{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.23.0-unstable-2026-10-21";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "adcc4293526a152ba0f81ba007c5a65d68e7e217";
    hash = "sha256-Emeygly8ePe5l6keJ52Y9h4jY+ra7ixW0ypPjttHrx8=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-Kcbd/If+63q4TRifEH3iZ+Doc5sF10MQLViBhsr0buE=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';
}
