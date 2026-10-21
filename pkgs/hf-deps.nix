{ pkgs }:
let
  version = "2.2.0";
in
pkgs.stdenv.mkDerivation {
  pname = "hf-deps";
  inherit version;

  nativeBuildInputs = [
    pkgs.uv
    pkgs.python312
    pkgs.cacert
  ];

  dontUnpack = true;
  # fixupPhase would rewrite #!/usr/bin/env shebangs (e.g. tqdm's
  # completion.sh) to absolute /nix/store paths, which fixed-output
  # derivations are forbidden from referencing.
  dontPatchShebangs = true;

  buildPhase = ''
    export UV_HTTP_TIMEOUT=600
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export HOME=$(mktemp -d)
    uv pip install \
      --target $out \
      --python ${pkgs.python312}/bin/python3 \
      --only-binary :all: \
      hf==${version} \
      huggingface-hub==${version} \
      hf-transfer==0.1.9 \
      hf-xet==1.7.0
    rm -rf $out/bin
  '';

  installPhase = "true";

  outputHashMode = "recursive";
  outputHash = "sha256-Cvf4228F9F935LIHTLxuaPh9AJIag2p1FlC7kOQKKgg=";
}
