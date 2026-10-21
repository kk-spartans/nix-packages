{ pkgs }:
let
  version = "0.0.24";
in
pkgs.stdenv.mkDerivation {
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
  outputHash = "sha256-xfgR9dW/ITQbBE0tEyzP+Wfenif6u3Bej8UrJMyhCIE=";
}
