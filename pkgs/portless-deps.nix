{ pkgs }:
let
  version = "0.15.12";
in
pkgs.stdenv.mkDerivation {
  pname = "portless-deps";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/portless/-/portless-${version}.tgz";
    hash = "sha256-6/Y+HJcHnJxoKaecSkRUCK0yZ8o8GlC5FnxOVHDjK1s=";
  };

  nativeBuildInputs = [ pkgs.bun ];

  unpackPhase = ''
    runHook preUnpack
    tar -xzf $src --strip-components=1
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR/home
    mkdir -p $HOME
    bun install --production --ignore-scripts --no-audit --no-fund
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/portless
    cp -r dist/. $out/libexec/portless/
    cp package.json $out/libexec/portless/package.json
    rm -rf $out/libexec/portless/node_modules/.cache
    runHook postInstall
  '';

  outputHashMode = "recursive";
  outputHash = "sha256-C/B3X4bnPPHqtHHPwZhr8uoNT8z422jRkFXDEVZR6I8=";
}
