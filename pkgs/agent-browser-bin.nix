{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "agent-browser";
  version = "0.32.3";

  src = pkgs.fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/archive/v${version}.tar.gz";
    hash = "sha256-u6fi6GwQ0nCH7GbO4TDwKyOWb8NkT+vMMB8UtDIpM9M=";
  };

  buildAndTestSubdir = "cli";
  cargoRoot = "cli";

  doCheck = false;

  cargoHash = "sha256-t+Lk72YPMH5SEl0HsS57WOFnvX6ryUA5Ec10jvOFeCk=";
}
