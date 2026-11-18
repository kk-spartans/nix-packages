{ pkgs }:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "pluely";
  version = "1.2.0";

  # Upstream only ships Linux binaries for x86_64 (deb/AppImage/rpm).
  src = pkgs.fetchurl {
    url = "https://github.com/iamsrikanthnani/pluely/releases/download/app-v${finalAttrs.version}/Pluely_${finalAttrs.version}_amd64.deb";
    hash = "sha256-gXuEIbC7eVdRXI8wQwfgY6GLkm6sHmdKQawH8TAUz4c=";
  };

  nativeBuildInputs = [
    pkgs.dpkg
    pkgs.autoPatchelfHook
    pkgs.wrapGAppsHook3
  ];

  # The deb is a bare Tauri binary; everything it links against is a normal
  # distro library, so autoPatchelf + the GTK/WebKit runtime is enough.
  buildInputs = [
    pkgs.webkitgtk_4_1
    pkgs.gtk3
    pkgs.libsoup_3
    pkgs.glib
    pkgs.gdk-pixbuf
    pkgs.cairo
    pkgs.pango
    pkgs.atk
    pkgs.openssl
    pkgs.libpulseaudio
    pkgs.libxcb
    pkgs.stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --extract "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/bin/pluely $out/bin/pluely

    for size in 32x32 128x128 256x256@2; do
      install -Dm644 "usr/share/icons/hicolor/$size/apps/pluely.png" \
        "$out/share/icons/hicolor/$size/apps/pluely.png"
    done

    install -Dm644 usr/share/applications/Pluely.desktop \
      $out/share/applications/com.srikanthnani.pluely.desktop

    substituteInPlace $out/share/applications/com.srikanthnani.pluely.desktop \
      --replace-fail "StartupWMClass=pluely" "StartupWMClass=com.srikanthnani.pluely"

    # Some runtimes/portals resolve the app id from the desktop file name or
    # window class as "pluely"; provide matching entries for discovery.
    for desktop in pluely.desktop Pluely.desktop; do
      install -Dm644 $out/share/applications/com.srikanthnani.pluely.desktop \
        $out/share/applications/$desktop
    done

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      # WebKitGTK can hit Wayland protocol errors (e.g. Error 71) on some
      # compositors/drivers with DMA-BUF rendering.
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
    )
  '';

  meta = {
    description = "Open source alternative to Cluely, a privacy-first real-time AI assistant";
    homepage = "https://github.com/iamsrikanthnani/pluely";
    license = pkgs.lib.licenses.gpl3Only;
    sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "pluely";
  };
})
