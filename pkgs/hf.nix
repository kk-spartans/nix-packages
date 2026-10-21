{ pkgs }:
let
  deps = pkgs.callPackage ./hf-deps.nix { };
in
pkgs.stdenv.mkDerivation {
  pname = "hf";
  inherit (deps) version;

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
