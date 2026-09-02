{ pkgs }:
pkgs.buildGoModule {
  pname = "spogo";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "spogo";
    rev = "87a990da7e2978f16938d8c7a8b708ddb96f7d78";
    hash = "sha256-GdvngM7i8V4A5Bi2B2d54qfPkdHUWc1C6cPK6Vgk3yA=";
  };

  subPackages = [ "cmd/spogo" ];
  vendorHash = "sha256-6wB/pBSXjZZaMtGrROMm87RxDzIfpdVPu6Ts+iXFxBA=";
}
