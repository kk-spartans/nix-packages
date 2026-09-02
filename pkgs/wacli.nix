{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "954102654b3a8f7adbb0a75085ba257adcd7e534";
    hash = "sha256-+R8wS+qGTLmYyXU5ibm3I2VKH//ZDR3OEcUYqbYndRM=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-ivxjc+sEbNmNNQ/oudZhje2ZFAathWqeLDKDx/tNwas=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';
}
