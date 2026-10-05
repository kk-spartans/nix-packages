{ pkgs }:
let
  go = pkgs.go_1_27.overrideAttrs (
    finalAttrs: _: {
      version = "1.27.1";
      src = pkgs.fetchurl {
        url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
        hash = "sha256-TkCKuuEm2Ra2FkYnGT8sVPDjyhMS1pO4bbRfhiqyOLE=";
      };
    }
  );
in
(pkgs.buildGoModule.override { inherit go; }) {
  pname = "discrawl";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "52470d9c7187afa92d9edc29d1d6f1fcbe8e503c";
    hash = "sha256-e0ryb2wDezPx3CAXBOV/i22smafFjFke6UAsCVOLLd0=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-KLOndHg5bj/saBJQ5wy9HnEMnLODcTJug98wUbM9xFI=";
}
