{ pkgs }:
let
  deps = pkgs.callPackage ./portless-deps.nix { };
in
pkgs.stdenv.mkDerivation {
  pname = "portless";
  inherit (deps) version;

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/libexec
    cp -r ${deps}/libexec/portless $out/libexec/portless
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/portless \
      --add-flags $out/libexec/portless/cli.js
    runHook postBuild
  '';

  installPhase = "true";

  meta = {
    description = "Portless: local HTTPS for development";
    homepage = "https://github.com/bcomnes/portless";
    license = pkgs.lib.licenses.mit;
    mainProgram = "portless";
  };
}
