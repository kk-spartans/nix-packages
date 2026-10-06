{ pkgs }:
let
  version = "0.2.8";

  # Fixed-output deps tree: the only derivation that touches the network.
  # `uv pip install --target` lays out pure site-packages; the generated
  # bin/ scripts (absolute shebangs = store references, forbidden in FODs)
  # are removed. The final package below provides its own launcher.
  deps = pkgs.stdenv.mkDerivation {
    pname = "discord-cli-deps";
    inherit version;

    nativeBuildInputs = [
      pkgs.uv
      pkgs.python312
      pkgs.cacert
    ];

    dontUnpack = true;

    buildPhase = ''
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export HOME=$(mktemp -d)
      uv pip install \
        --target $out \
        --python ${pkgs.python312}/bin/python3 \
        --only-binary :all: \
        kabi-discord-cli==${version}
      rm -rf $out/bin
    '';

    installPhase = "true";

    outputHashMode = "recursive";
    outputHash = "sha256-aP0H1O8sBjm4WZ6XtgsknkJ1rjM/9ohI2T4DsInIZP4=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "discord-cli";
  inherit version;

  dontUnpack = true;

  buildPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/discord <<EOF
    #!${pkgs.python312}/bin/python
    import sys
    sys.path.insert(0, "${deps}")
    from discord_cli.cli.main import cli
    if __name__ == "__main__":
        cli()
    EOF
    chmod +x $out/bin/discord
  '';

  installPhase = "true";

  meta.mainProgram = "discord";
}
