{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "pixie-sddm";

  src = pkgs.fetchFromGitHub {
    owner = "xCaptaiN09";
    repo = "pixie-sddm";
    rev = "1e1a863761f742e8d509d569382b17c112e29fdc";
    hash = "sha256-wV5XnU+4ME1HZAsGad+Lb+zTCqryn0WWo75FaoOFefc=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/pixie
    cp -r * $out/share/sddm/themes/pixie/
  '';
}
