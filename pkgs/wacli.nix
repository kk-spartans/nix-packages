{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "a4f23eef7395473931e3a44c93eacd6ebebdc313";
    hash = "sha256-hbJcS22EtgxgJ0wK3dlqkBF/FTAs4zdOthr3st/4x3o=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-E/LnctFkSYMctq2wJaCjjUip7UPniNVEVwxQ6ewUIxo=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';
}
