{ pkgs }:
pkgs.buildGoModule {
  pname = "wacli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "97e14efdf91a7c9de1b68845321eb6355943b5f5";
    hash = "sha256-i7hZxLQkde4fzoFS7977gLFxoCsAVnmgdyqtBITHTxM=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-Ymm/hn1xvMA9MnAtSQxMWoPDx5qNFv9bHR9D6031upI=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';
}
