{ pkgs }:
pkgs.buildGoModule {
  pname = "gogcli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "414e2ff8afa281ec3d9f0cdb057bdbc53386db91";
    hash = "sha256-G2FF1NivKKZdtqonRQqZh+PtwscResIxtLLUMNUzBac=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-EBZhRTOgImlFWoTx0mYLtBLGC/GPBUoXGcpAswqxVdw=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
