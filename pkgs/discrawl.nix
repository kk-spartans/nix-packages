{ pkgs }:
let
  go_1_26_4 = pkgs.go.overrideAttrs (old: {
    version = "1.26.4";
    src = pkgs.fetchurl {
      url = "https://go.dev/dl/go1.26.4.src.tar.gz";
      hash = "sha256-T2aKMvv8ETLmqIH7lowvHa2mMUkqM5IRc1+7JVpCYC0=";
    };
  });
in (pkgs.buildGoModule.override { go = go_1_26_4; }) {
  pname = "discrawl";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "670994a45f610ce1c48a088ef5c5769b9c1badf4";
    hash = "sha256-8FqnG1PYkS79BhYzFzgbG1lOcv71AhNIFAunOhgnLU0=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-ZL7YhhJVsUBTCwUJVSsHlBQal0jlbHuXgTSpBT++YKA=";
}
