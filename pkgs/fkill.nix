{ pkgs }:
let
  version = "9.0.0";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/fkill-cli/-/fkill-cli-${version}.tgz";
    hash = "sha256-6S6FgJer78LBQ4+wrO6uhqT3BZA0wo+0g++qdiukXLI=";
  };

  deps = pkgs.stdenv.mkDerivation {
    pname = "fkill-deps";
    inherit version src;

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
  };
in
pkgs.stdenv.mkDerivation {
  pname = "fkill";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/libexec
    cp -r ${deps}/libexec/fkill $out/libexec/fkill
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/fkill \
      --add-flags $out/libexec/fkill/cli.js
    runHook postBuild
  '';

  installPhase = "true";

  meta = {
    description = "Fabulously kill processes";
    homepage = "https://github.com/sindresorhus/fkill-cli";
    license = pkgs.lib.licenses.mit;
    mainProgram = "fkill";
  };
}
