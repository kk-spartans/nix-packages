{ pkgs }:
pkgs.buildGoModule {
  pname = "wacli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "bbeaebf3a15a3b95da797f97c44c6fb92746974d";
    hash = "sha256-sv7luhHZ4lD2M5AycEY86C5JMuOAJMssq2cANLM4M0Q=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-N5VIGCfMuaMbSuxwQLXUOCBGJ23WM4+3UA6vZhvxOPs=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';
}
