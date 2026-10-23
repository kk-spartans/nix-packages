{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.24.0-unstable-2026-10-23";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "5578d1b6892f50a8f2329b11a6b6e27a1a81f88b";
    hash = "sha256-yr3wEjg8uZvdtOkkKdwMrnXjb/MLNMXh8ZODOp1PAX4=";
  };

  subPackages = [ "cmd/wacli" ];
  vendorHash = "sha256-hZLUFdXreQyI6rZcKvQWN5Vi628jlEk65+Mcvlj9K34=";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  postInstall = ''
    $out/bin/wacli completion fish > wacli.fish
    installShellCompletion --fish --name wacli.fish wacli.fish
  '';

  meta.mainProgram = "wacli";
}
