{ pkgs }:
pkgs.buildGoModule {
  pname = "gogcli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "03d192ff9bad1f0540e7b37a527990558ed8a040";
    hash = "sha256-o2o/VTUj6b2lJjdsS8p3WIXlXSA/P6iN/fFtukn0+rU=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-o84M81MKbXMNBh1QXyZjSoUS5Oq8SjC6HQUOM2I2Rbg=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
