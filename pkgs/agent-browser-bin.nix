{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "agent-browser";
  version = "0.36.0";

  src = pkgs.fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/archive/v${version}.tar.gz";
    hash = "sha256-1BQBWFLeAWXEalrb8EFZLd8y7nkNdJBh+u9stDwdPFk=";
  };

  buildAndTestSubdir = "cli";
  cargoRoot = "cli";

  doCheck = false;

  cargoHash = "sha256-6xphNOYi+tJvFlprY8DCVw1XzVFapqFQfeIy0w2pyCs=";
}
