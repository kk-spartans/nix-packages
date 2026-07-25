{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "pixie-sddm";

  src = pkgs.fetchFromGitHub {
    owner = "xCaptaiN09";
    repo = "pixie-sddm";
    rev = "main";
    hash = "sha256-1PDWX8bJfc0HYMW9MsxWwDXDoYy5aaehUWr7FW3yR9U=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/pixie
    cp -r * $out/share/sddm/themes/pixie/
  '';
}
