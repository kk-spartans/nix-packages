{
  lib,
  stdenv,
  fetchurl,
  makeBinaryWrapper,
}:
stdenv.mkDerivation rec {
  pname = "t3-unwrapped";
  version = "0.1.3-nightly.20261023.3566";

  # Upstream publishes the self-contained CLI as a release archive. The npm
  # packages are just launchers (0.1.x even downloads this archive at runtime),
  # so the archive is the real artifact.
  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-x64.tar.gz";
    hash = "sha256-STGGdxgG5DIZ8NkOwn5oiM+eBOL/ZvUHFweGppLY6Ww=";
  };

  sourceRoot = "t3-${version}-linux-x64";

  # Node SEA: the node executable plus the appended application blob. Stripping
  # (or patching the ELF headers) corrupts the blob and the process dies with
  # SIGILL before main(), so leave the binary untouched.
  dontStrip = true;

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/t3
    cp -a . $out/libexec/t3/
    mkdir -p $out/bin
    # The bundled `.node` modules and the executable itself need libstdc++ /
    # libatomic, which the wrapper injects instead of patching the SEA binary.
    makeWrapper $out/libexec/t3/t3 $out/bin/t3 \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          stdenv.cc.cc.lib
        ]
      }
    runHook postInstall
  '';

  meta = {
    description = "T3 Code headless server (upstream release archive)";
    homepage = "https://t3.codes";
    license = lib.licenses.mit;
    mainProgram = "t3";
    platforms = [ "x86_64-linux" ];
  };
}
