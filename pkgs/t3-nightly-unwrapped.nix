{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  makeBinaryWrapper,
}:
let
  version = "0.0.46-nightly.20261005.2676";

  t3-linux-x64 = fetchurl {
    url = "https://registry.npmjs.org/@t3code/t3-linux-x64/-/t3-linux-x64-${version}.tgz";
    hash = "sha256-RRARlEiPs9nQo3pSkR1b3mkVYpOM6sCYfnKi9Uhif4o=";
  };
in
buildNpmPackage {
  pname = "t3-nightly-unwrapped";
  inherit version;

  src = ../t3-lock;

  npmDepsHash = "sha256-ez2FZWajYt1ajUQ4ctZlM8hKGuF5T34YEXPRFMy16kc=";

  nativeBuildInputs = [ makeBinaryWrapper ];

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/t3-nightly
    cp -r node_modules $out/libexec/t3-nightly/
    mkdir -p $out/libexec/t3-nightly/node_modules/@t3code/t3-linux-x64
    tar -xzf ${t3-linux-x64} -C $out/libexec/t3-nightly/node_modules/@t3code/t3-linux-x64 --strip-components=1
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/t3 \
      --add-flags $out/libexec/t3-nightly/node_modules/t3/bin/t3.js
    runHook postInstall
  '';

  meta = {
    description = "T3 nightly via npm";
    homepage = "https://t3.codes";
    license = lib.licenses.mit;
    mainProgram = "t3";
  };
}
