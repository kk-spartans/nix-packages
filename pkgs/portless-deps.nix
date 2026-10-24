{ pkgs }:
let
  version = "0.15.11";
in
pkgs.stdenv.mkDerivation {
  pname = "portless-deps";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/portless/-/portless-${version}.tgz";
    hash = "sha256-RN8KKVoh7XGCxk7utpmU6INLibBOk4NRoZy36zGreuM=";
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
  outputHash = "sha256-7ZdEBl49RBzl07MfvbYnCzzj5df8pTN04FXJzdjowG4=";
}
