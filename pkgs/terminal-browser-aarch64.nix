{ pkgs }:
# The aarch64 tarball lives in its own derivation so nix-update can move its
# version + hash without touching the x86_64 pin (and vice versa).
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "terminal-browser-aarch64-src";
  version = "0.15.0";

  src = pkgs.fetchurl {
    url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v${version}/terminal-browser-linux-arm64.tar.gz";
    hash = "sha256-FHT/LFZU75qBC4PtxRSTgWNYbx6ZQzOJH+EJyB+h6X8=";
  };

  dontUnpack = true;
  installPhase = "cp $src $out";
}
