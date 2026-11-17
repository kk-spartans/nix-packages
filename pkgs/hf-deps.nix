{ pkgs }:
let
  version = "2.4.0";
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
    # Fully pinned + hashed lock (pkgs/hf-requirements.txt). Resolving
    # transitives here made the FOD hash rot on upstream releases.
    uv pip install \
      --target $out \
      --python ${pkgs.python312}/bin/python3 \
      --only-binary :all: \
      --require-hashes \
      --requirement ${./hf-requirements.txt}
    rm -rf $out/bin
  '';

  installPhase = "true";

  outputHashMode = "recursive";
  outputHash = "sha256-NSwxa/8Xp2Psa+C0Du583/+UC5BvDrIrRZn6iCNo/2Y=";
}
