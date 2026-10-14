{ pkgs }:
let
  version = "0.15.7";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/portless/-/portless-${version}.tgz";
    hash = "sha256-ghfH91djeBkcMk5vGi058xqceHo072g3K25o+VbJqPw=";
  };

  deps = pkgs.stdenv.mkDerivation {
    pname = "portless-deps";
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
      mkdir -p $out/libexec/portless
      cp -r dist/. $out/libexec/portless/
      cp package.json $out/libexec/portless/package.json
      rm -rf $out/libexec/portless/node_modules/.cache
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-ZKoflq5hPuPKaefIueRnilG7E/P6Z++5JVKPKnoj+jk=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "portless";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/libexec
    cp -r ${deps}/libexec/portless $out/libexec/portless
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/portless \
      --add-flags $out/libexec/portless/cli.js
    runHook postBuild
  '';

  installPhase = "true";

  meta = {
    description = "Portless: local HTTPS for development";
    homepage = "https://github.com/bcomnes/portless";
    license = pkgs.lib.licenses.mit;
    mainProgram = "portless";
  };
}
