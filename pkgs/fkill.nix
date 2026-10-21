{ pkgs }:
let
  deps = pkgs.callPackage ./fkill-deps.nix { };
in
pkgs.stdenv.mkDerivation {
  pname = "fkill";
  inherit (deps) version;

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/libexec
    cp -r ${deps}/libexec/fkill $out/libexec/fkill
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/fkill \
      --add-flags $out/libexec/fkill/cli.js
    runHook postBuild
  '';

  installPhase = "true";

  meta = {
    description = "Fabulously kill processes";
    homepage = "https://github.com/sindresorhus/fkill-cli";
    license = pkgs.lib.licenses.mit;
    mainProgram = "fkill";
  };
}
