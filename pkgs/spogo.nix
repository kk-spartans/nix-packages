{ pkgs }:
pkgs.buildGoModule {
  pname = "spogo";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "spogo";
    rev = "3d4edc230f5ece848b81642e95f3682f3ed3e8d7";
    hash = "sha256-ceUiK1gyIFwnKo+NOAAGVD22A+rCMpa56LuZ0YO6Mxs=";
  };

  subPackages = [ "cmd/spogo" ];
  vendorHash = "sha256-IZy7LO79+b5KCags5P7BAtwk0dqsXopuGnHCoiaRtZo=";
}
