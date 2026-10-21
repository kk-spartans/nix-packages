{ pkgs }:
let
  deps = pkgs.callPackage ./ocrmypdf-deps.nix { };
  inherit (pkgs) lib;
in
pkgs.stdenv.mkDerivation {
  pname = "ocrmypdf";
  inherit (deps) version;

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

  # ocrmypdf shells out to ghostscript (rendering), tesseract (OCR), qpdf,
  # unpaper (--clean/--deskew) and pngquant/jbig2enc/jbig2dec (--optimize).
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
          pkgs.unpaper
          pkgs.pngquant
          pkgs.jbig2enc
          pkgs.jbig2dec
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
