{ pkgs }:
pkgs.buildGoModule {
  pname = "gogcli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "8e9234525cf4b8dc7d15e1f91cdf504318411f99";
    hash = "sha256-upNsdqcLTpA+gqz1LIw6WIeXvnNKQGGkR8ObhTa2pvY=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-eVNA6BoZkxUkX1qYrO/ILXMxPfDyu/uuZMDi+8hpovM=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
