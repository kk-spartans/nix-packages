{ pkgs }:
let
  version = "0.0.24";

  deps = pkgs.stdenv.mkDerivation {
    pname = "t1code-deps";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@maria_rcks/t1code/-/t1code-${version}.tgz";
      hash = "sha256-XFMHMH6WAE9y72LZKylVQcTOq+lZR45d6fpJRSN57UQ=";
    };

    nativeBuildInputs = [ pkgs.bun ];

    configurePhase = ''
      mkdir -p $TMPDIR/package
      tar -xzf $src -C $TMPDIR/package --strip-components=1
      cd $TMPDIR/package
      substituteInPlace package.json \
        --replace-fail '"effect": "catalog:"' '"effect": "4.0.0-beta.73"'
    '';

    buildPhase = ''
      bun install --production --ignore-scripts --no-audit --no-fund
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/t1code
      cp -r package.json README.md bin dist node_modules $out/libexec/t1code/
      rm -rf $out/libexec/t1code/node_modules/.cache
      rm -f $out/libexec/t1code/node_modules/.package-lock.json
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-MUPSzHxfw43XGIDJfLPWCheTxpHXekxtQd38AFC9KlM=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "t1code";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

  buildPhase = ''
    mkdir -p $out/libexec/t1code
    cp -r ${deps}/libexec/t1code/. $out/libexec/t1code/
    mkdir -p $out/bin
    makeWrapper ${pkgs.bun}/bin/bun $out/bin/t1code \
      --add-flags $out/libexec/t1code/bin/t1code.js
    ln -s t1code $out/bin/t1
  '';

  installPhase = "true";

  meta = {
    description = "Terminal-first T3 Code fork with an OpenTUI client";
    homepage = "https://github.com/maria-rcks/t1code";
    license = pkgs.lib.licenses.mit;
    mainProgram = "t1code";
    platforms = [ "x86_64-linux" ];
  };
}
