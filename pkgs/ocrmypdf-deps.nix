{ pkgs }:
let
  version = "17.13.0";
in
pkgs.stdenv.mkDerivation {
  pname = "ocrmypdf-deps";
  inherit version;

  nativeBuildInputs = [
    pkgs.uv
    pkgs.python312
    pkgs.cacert
  ];

  dontUnpack = true;
  # fixupPhase would rewrite #!/usr/bin/env shebangs to absolute
  # /nix/store paths, which fixed-output derivations are forbidden
  # from referencing.
  dontPatchShebangs = true;

  buildPhase = ''
    export UV_HTTP_TIMEOUT=600
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export HOME=$(mktemp -d)
    # Fully pinned + hashed lock (pkgs/ocrmypdf-requirements.txt, generated
    # with `uv pip compile --generate-hashes`). Resolving unpinned here made
    # the FOD hash rot every time any transitive dep released.
    uv pip install \
      --target $out \
      --python ${pkgs.python312}/bin/python3 \
      --only-binary :all: \
      --require-hashes \
      --index-strategy unsafe-best-match \
      --extra-index-url https://download.pytorch.org/whl/cu124 \
      --requirement ${./ocrmypdf-requirements.txt}
    rm -rf $out/bin
  '';

  installPhase = "true";

  outputHashMode = "recursive";
  outputHash = "sha256-/l29rTFLW3cKrzValx3gg3cpOBJLCuH0P7atEjuMjyI=";
}
