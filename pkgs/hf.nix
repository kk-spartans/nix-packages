{ pkgs }:
let
  version = "2.1.1";

  # Fixed-output deps tree: the only derivation that touches the network.
  # `uv pip install --target` lays out pure site-packages; the generated
  # bin/ scripts (absolute shebangs = store references, forbidden in FODs)
  # are removed. The final package below provides its own launcher.
  # NOTE: the CLI now lives in the `hf` PyPI package (thin wrapper over
  # huggingface_hub); installing huggingface-hub alone no longer yields a
  # working `hf` binary.
  deps = pkgs.stdenv.mkDerivation {
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
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export HOME=$(mktemp -d)
      uv pip install \
        --target $out \
        --python ${pkgs.python312}/bin/python3 \
        --only-binary :all: \
        hf==${version} \
        huggingface-hub==${version} \
        hf-transfer==0.1.9 \
        hf-xet==1.6.0
      rm -rf $out/bin
    '';

    installPhase = "true";

    outputHashMode = "recursive";
    outputHash = "sha256-0VnUcq94TBQWk/l0moofS1DQW0RkPjxyQ/38sDB0/pQ=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "hf";
  inherit version;

  dontUnpack = true;

  buildPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/hf <<EOF
    #!${pkgs.python312}/bin/python
    import sys
    sys.path.insert(0, "${deps}")
    from huggingface_hub.cli.hf import main
    if __name__ == "__main__":
        sys.exit(main())
    EOF
    chmod +x $out/bin/hf
  '';

  installPhase = "true";

  meta.mainProgram = "hf";
}
