{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "6f17fc17ba10a7faff4b7cb2867c4b3a16b9a46f";
    hash = "sha256-5XIFhpjn5e1EOziV8WBpR/Q/6D0lt+6aGtbshigX37Q=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-Kcbd/If+63q4TRifEH3iZ+Doc5sF10MQLViBhsr0buE=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';
}
