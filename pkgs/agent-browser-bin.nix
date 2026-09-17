{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "agent-browser";
  version = "0.37.1";

  src = pkgs.fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/archive/v${version}.tar.gz";
    hash = "sha256-cE9MP9x7wvZKZnSxLQ8NgfcfM9VOI6rYLqvgc3Nak2I=";
  };

  buildAndTestSubdir = "cli";
  cargoRoot = "cli";

  doCheck = false;

  cargoHash = "sha256-ziN4UMeEcgsD5BDXWjffreGjyew7oTUtq59b/Um8Dfk=";
}
