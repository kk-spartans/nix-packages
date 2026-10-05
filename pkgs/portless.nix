{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  pname = "portless";
  version = "0.15.7";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/portless/-/portless-${version}.tgz";
    hash = "sha256-ghfH91djeBkcMk5vGi058xqceHo072g3K25o+VbJqPw=";
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
    cp -r dist/. $out/bin/
    mv $out/bin/cli.js $out/bin/portless
  '';

  installPhase = "true";

  outputHashMode = "recursive";
  outputHash = "sha256-+G1BDnW3ur5mBtc/1Cwjfq61SFbNfDT2oecVOpygXF4=";
}
