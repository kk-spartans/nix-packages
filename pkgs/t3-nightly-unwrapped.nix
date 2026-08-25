{
  lib,
  buildNpmPackage,
  nodejs,
  makeBinaryWrapper,
}:
buildNpmPackage {
  pname = "t3-nightly-unwrapped";
  version = "0.0.34-nightly.20260825.1185";

  src = ../t3-lock;

  npmDepsHash = "sha256-Rf3uQHZJaX8ONIb6sbE4qkjGpS/Au1RjUAToGvn0UWo=";

  nativeBuildInputs = [ makeBinaryWrapper ];

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/t3-nightly
    cp -r node_modules $out/libexec/t3-nightly/
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/t3 \
      --add-flags $out/libexec/t3-nightly/node_modules/t3/dist/bin.mjs
    runHook postInstall
  '';

  meta = {
    description = "T3 nightly via npm";
    homepage = "https://t3.codes";
    license = lib.licenses.mit;
    mainProgram = "t3";
  };
}
