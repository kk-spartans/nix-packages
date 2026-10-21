{ pkgs }:
let
  deps = pkgs.callPackage ./t1code-deps.nix { };
in
pkgs.stdenv.mkDerivation {
  pname = "t1code";
  inherit (deps) version;

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

  buildPhase = ''
    mkdir -p $out/libexec/t1code
    cp -r ${deps}/libexec/t1code/. $out/libexec/t1code/
    mkdir -p $out/bin
    makeWrapper ${pkgs.bun}/bin/bun $out/bin/t1code \
      --add-flags $out/libexec/t1code/bin/t1code.js
    ln -s t1code $out/bin/t1
  '';

  installPhase = "true";

  meta = {
    description = "Terminal-first T3 Code fork with an OpenTUI client";
    homepage = "https://github.com/maria-rcks/t1code";
    license = pkgs.lib.licenses.mit;
    mainProgram = "t1code";
    platforms = [ "x86_64-linux" ];
  };
}
