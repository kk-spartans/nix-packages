{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "aw-watcher-lastfm";
  version = "0.6.0";

  src = pkgs.fetchzip {
    url = "https://github.com/0xbrayo/aw-watcher-lastfm/releases/download/v0.6.0/aw-watcher-lastfm-linux.zip";
    hash = "sha256-+n5zSHbA43p30Bi0UE0F7qT2fRCcU2TwETsDTYj1ebs=";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = with pkgs; [ openssl zlib stdenv.cc.cc.lib ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src/aw-watcher-lastfm" "$out/bin/aw-watcher-lastfm"
    runHook postInstall
  '';
}
