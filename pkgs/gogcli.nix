{ pkgs }:
pkgs.buildGoModule {
  pname = "gogcli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "469b823aead21279167577bf840f8084120ae274";
    hash = "sha256-a8/gU3GpbP7IA54DtsYXvd68OSYFj3jyJrtOoCT2g7Y=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-9LZaq+sdtXChTqOqDex28/UZP7du8QJoEI/4o1yUHVU=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
