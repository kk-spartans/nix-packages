{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "ocrmypdf";
  version = "17.8.1";

  nativeBuildInputs = [ pkgs.uv pkgs.python312 ];

  dontUnpack = true;

  buildPhase = ''
    export HOME=$(mktemp -d)
    uv venv --python ${pkgs.python312}/bin/python3
    source .venv/bin/activate
    uv pip install \
      --extra-index-url https://download.pytorch.org/whl/cu124 \
      ocrmypdf==17.8.1 \
      ocrmypdf-easyocr==0.3.0
    mkdir -p $out/bin
    cp $PWD/.venv/bin/ocrmypdf $out/bin/ocrmypdf
    chmod +x $out/bin/ocrmypdf
    sed -i '1c\#!/usr/bin/env python3' $out/bin/ocrmypdf
  '';

  installPhase = "true";

  outputHashMode = "recursive";
  outputHash = "sha256-FOOtTBBY/x27lBgBoaUjpNG4I/OTHkAA1ydr5hWW8io=";
}
