{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "discrawl";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "b1ea76ebbb40196cba9e85501a267c7bd01cdac8";
    hash = "sha256-yIjLe93JgG0QEaStazx7zAideG4G2wgeXftLCuC+sr0=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-F567TQwzUXZgG07Na7g7X6E5Lhzoq6+QkSS2QWzwb8o=";
}
