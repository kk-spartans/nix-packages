{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "aw-watcher-lastfm";
  version = "0.6.1";

  src = pkgs.fetchzip {
    url = "https://github.com/0xbrayo/aw-watcher-lastfm/releases/download/v0.6.1/aw-watcher-lastfm-linux.zip";
    hash = "sha256-GxwBE9Df8wb+OTSW5N93z81mM5iFvgR2IN/phmq9wFk=";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = with pkgs; [
    openssl
    zlib
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src/aw-watcher-lastfm" "$out/bin/aw-watcher-lastfm"
    runHook postInstall
  '';
}
