{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "pixie-sddm";

  src = pkgs.fetchFromGitHub {
    owner = "xCaptaiN09";
    repo = "pixie-sddm";
    rev = "505b32c629b9183de70cc45f424e79bffe22e379";
    hash = "sha256-YCYnPGxm6LWpkbm8kE21QEGheIOHbk1XE5ke08NM05k=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/pixie
    cp -r * $out/share/sddm/themes/pixie/
  '';
}
