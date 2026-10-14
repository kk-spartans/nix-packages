{ lib, pkgs }:
let
  version = "17.13.0";

  # Fixed-output deps tree: the only derivation that touches the network.
  # `uv pip install --target` lays out pure site-packages; the generated
  # bin/ scripts (absolute shebangs = store references, forbidden in FODs)
  # are removed. The final package below provides its own launcher.
  deps = pkgs.stdenv.mkDerivation {
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
      uv pip install \
        --target $out \
        --python ${pkgs.python312}/bin/python3 \
        --only-binary :all: \
        --extra-index-url https://download.pytorch.org/whl/cu124 \
        ocrmypdf==${version} \
        ocrmypdf-easyocr==0.3.0
      rm -rf $out/bin
    '';

    installPhase = "true";

    outputHashMode = "recursive";
    outputHash = "sha256-R4BqREiHwQU8u8WNEjn8GV06t8oaTV5F7zp2g2QDvQA=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "ocrmypdf";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  # The launcher only adds the deps tree to sys.path: copying
  # bin/ocrmypdf out of a venv and rewriting its shebang produced a binary
  # that died with ModuleNotFoundError on every single invocation.
  buildPhase = ''
    runHook preBuild
    mkdir -p $out/bin
    cat > $out/bin/ocrmypdf <<EOF
    #!${pkgs.python312}/bin/python
    import sys
    sys.path.insert(0, "${deps}")
    from ocrmypdf.__main__ import run
    if __name__ == "__main__":
        sys.exit(run())
    EOF
    chmod +x $out/bin/ocrmypdf
    runHook postBuild
  '';

  installPhase = "true";

  # ocrmypdf shells out to ghostscript (rendering), tesseract (OCR) and qpdf.
  # Without them on PATH at run time it only fails once you actually use it.
  # The bundled wheel .so files (pikepdf, torch) also need libstdc++,
  # which plain python3 does not provide.
  postFixup = ''
    wrapProgram $out/bin/ocrmypdf \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.ghostscript
          pkgs.tesseract
          pkgs.qpdf
        ]
      } \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]} \
      --set TESSDATA_PREFIX "${pkgs.tesseract}/share/tessdata"
  '';

  meta = {
    description = "OCRmyPDF: add a searchable OCR text layer to scanned PDFs";
    mainProgram = "ocrmypdf";
  };
}
