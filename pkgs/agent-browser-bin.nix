{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "agent-browser";
  version = "0.38.1";

  src = pkgs.fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/archive/v${version}.tar.gz";
    hash = "sha256-xJ0yBlBYsGtgrFBe0LVi9Gmmq2hWblEPdRgWZ5Hax+s=";
  };

  buildAndTestSubdir = "cli";
  cargoRoot = "cli";

  doCheck = false;

  cargoHash = "sha256-Ei26Iz0qMqayucULLCSwN+fjw0VJ3S2L2A4vGhfYGqI=";
}
