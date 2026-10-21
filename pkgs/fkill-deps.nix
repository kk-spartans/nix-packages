{ pkgs }:
let
  version = "9.0.0";
in
pkgs.stdenv.mkDerivation {
  pname = "fkill-deps";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/fkill-cli/-/fkill-cli-${version}.tgz";
    hash = "sha256-6S6FgJer78LBQ4+wrO6uhqT3BZA0wo+0g++qdiukXLI=";
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
    mkdir -p $out/libexec/fkill
    # cli.js + package.json must sit side by side: meow reads the version
    # from the nearest package.json, otherwise `--version` prints
    # "No version found".
    cp cli.js $out/libexec/fkill/cli.js
    cp package.json $out/libexec/fkill/package.json
    cp -r node_modules $out/libexec/fkill/node_modules
    rm -rf $out/libexec/fkill/node_modules/.cache
    runHook postInstall
  '';

  outputHashMode = "recursive";
  outputHash = "sha256-e6J0OxyUm6gP35ArkRkvmpJQ/3OeeHzUN2FM6Fp5Pao=";
}
