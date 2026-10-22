{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.46.0-unstable-2026-10-22";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "ea582609ec6ec4efb169d48fb7610d47e4acdca2";
    hash = "sha256-yzbmRqcu3x0oQk1e4DSwE1Snf8BkD/syazT7F0OKAhU=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-eVNA6BoZkxUkX1qYrO/ILXMxPfDyu/uuZMDi+8hpovM=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
