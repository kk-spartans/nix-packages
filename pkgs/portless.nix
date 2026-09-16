{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  pname = "portless";
  version = "0.15.6";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/portless/-/portless-${version}.tgz";
    hash = "sha256-SPFeXWPEd4RTTdletSAefmWM5D6uG3q5YNNLbWe5VIo=";
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
  outputHash = "sha256-6boyfSGtDnHlEqjBBIIthhlaile5LUMKZ+5oNVV1i1U=";
}