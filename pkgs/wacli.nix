{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "wacli";
  version = "0.25.0-unstable-2026-10-23";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "wacli";
    rev = "c1e7c13c3f775ef9271259334f4614c3b834e917";
    hash = "sha256-fRgnCvxTApmpUXNCq9ARsKmUV0Pc9/fidvnnf4v2+Ak=";
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
