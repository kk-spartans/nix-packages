{ pkgs }:
let
  version = "0.7.6";
  target =
    if pkgs.stdenv.isAarch64 then "linux-arm64"
    else "linux-x64";
  srcHash =
    if pkgs.stdenv.isAarch64
    then "sha256-cVD6l0YNmDS/1r8eSnH25TitvH/S7Wh50EV/zMoyPUY="
    else "sha256-vjZ+fZQsW2/jmjJxBejcPkQS2SR0riukKrBWRS7E4sQ=";
in
pkgs.stdenv.mkDerivation {
  pname = "terminal-browser";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v${version}/terminal-browser-${target}.tar.gz";
    hash = srcHash;
  };

  sourceRoot = "terminal-browser";

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  buildInputs = with pkgs; [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libGL
    libxcb
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    udev
  ];

  # libEGL.so.1/libGLESv2.so.2 are dlopen'd by name at runtime (not DT_NEEDED),
  # so autoPatchelf won't add them to the rpath on its own.
  # Without them the GPU process dies and the whole canvas renders white.
  appendRunpaths = [ "${pkgs.libGL}/lib" ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a . $out/
    sed -i "2a export NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" $out/bin/terminal-browser
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "A real browser that runs directly inside your terminal";
    homepage = "https://terminal-browser.sh/";
    license = licenses.mit;
    mainProgram = "terminal-browser";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
