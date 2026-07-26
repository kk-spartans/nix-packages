{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  pname = "fkill";
  version = "9.0.0";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/fkill-cli/-/fkill-cli-${version}.tgz";
    hash = "sha256-6S6FgJer78LBQ4+wrO6uhqT3BZA0wo+0g++qdiukXLI=";
  };

  nativeBuildInputs = [ pkgs.bun ];

  configurePhase = ''
    export HOME=$TMPDIR/home
    mkdir -p $HOME
    cp $src package.tgz
    tar -xzf package.tgz --strip-components=1
  '';

  buildPhase = ''
    bun install --production --no-save
    mkdir -p $out/bin
    cp cli.js $out/bin/fkill
    cp -r node_modules $out/bin/node_modules
  '';

  installPhase = "true";

  outputHashMode = "recursive";
  outputHash = "sha256-P5KsB3E05PBImB9SVI1wBmMhyUdObIntud/zefhapfI=";
}
