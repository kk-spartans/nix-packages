{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "6f64e5923bc8ee5963bd60dfcf41a323c9494b33";
    hash = "sha256-qkUpWMqEuDheHLnulkSwCF5aRKN+/WXaOAJUcuYOeC0=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-cRG3t85qMvRNjl6DWGHx2FPfdR8yMpL+PJoMhWy2qbI=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';
}
