{ pkgs }:
let
  version = "0.16.0";
in
pkgs.stdenv.mkDerivation {
  pname = "portless-deps";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/portless/-/portless-${version}.tgz";
    hash = "sha256-L2BeIv1pDmrl+zO3OV6U7+92B9e0RuX17PfBUl6k6N8=";
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
  outputHash = "sha256-L6nFRW+vBDRfYHamoL12ip5CTRHnQIVIMi1o8af0DlM=";
}
