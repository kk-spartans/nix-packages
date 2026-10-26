{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.25.0-unstable-2026-10-26";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "00fe5ef6601b427fd800074a526960c9379cc1c0";
    hash = "sha256-vxLM8Fz8pURqg18rLqtgWJHQu2USP8qJNsMwxPepLG4=";
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
