{ pkgs }:
pkgs.buildGoModule {
  pname = "gogcli";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "gogcli";
    rev = "dafe80460ffe67a22d2bec39ce5d0a6eda64188c";
    hash = "sha256-qg0BmUNZbGCQWxHrqDO4BXL+SB5180RlBR6kMQ69wdQ=";
  };

  subPackages = [ "cmd/gog" ];
  vendorHash = "sha256-fof2DVm6Cn1ZW7gKSYLHX6M6nPbtYBn6EKinptjhhrE=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/gog completion fish > gog.fish
    installShellCompletion --fish --name gog.fish gog.fish
  '';
}
