{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.46.0-unstable-2026-10-21";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "ec34fedc23dd9d3e90f0401144cec42e06a50783";
    hash = "sha256-TWlLj2YoGvynUYDnv9GKle9vSyerUcJqorifxe3VUDc=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-eVNA6BoZkxUkX1qYrO/ILXMxPfDyu/uuZMDi+8hpovM=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
