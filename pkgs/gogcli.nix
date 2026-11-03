{ pkgs }:
pkgs.buildGoModule rec {
  pname = "gogcli";
  version = "0.47.1-unstable-2026-11-03";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "80f45bbb9f89bd2945620253d7fb243f036435fa";
    hash = "sha256-D5Te+/5YpigikQzqdPuOajbc14PuP2zYQzd7pelGn3Q=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-DESZMHxLfhPPjHruEXd2glJWjAlUR2rHEfyyV+N1q/A=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
