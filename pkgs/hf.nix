{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "hf";
  version = "1.29.0";

  nativeBuildInputs = [ pkgs.uv pkgs.python312 pkgs.cacert ];

  dontUnpack = true;

  buildPhase = ''
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export HOME=$(mktemp -d)
    uv venv --python ${pkgs.python312}/bin/python3
    source .venv/bin/activate
    uv pip install \
      --only-binary :all: \
      huggingface-hub==1.29.0 \
      hf-transfer==0.1.9 \
      hf-xet==1.6.0
    mkdir -p $out/bin
    cp $PWD/.venv/bin/hf $out/bin/hf
    chmod +x $out/bin/hf
    sed -i '1c\#!/usr/bin/env python3' $out/bin/hf
  '';

  installPhase = "true";

  outputHashMode = "recursive";
  outputHash = "sha256-jrddaOxnCY8ImQ6xFmQicCucHBzp4wUvl9JXBc8+SBU=";
}
