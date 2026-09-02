{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "tokscale";
  version = "4.15.0";

  src = pkgs.fetchurl {
    url = "https://github.com/junhoyeo/tokscale/archive/v${version}.tar.gz";
    hash = "sha256-3GvDcAY2PWuyEUuM3njRTos7sY3OGUCXuqywYDn81y4=";
  };

  cargoHash = "sha256-nvgvVFDthLYLb20huX4iNxyeRDVPP5PyxUhrk3DvJhI=";

  doCheck = false;

  buildInputs = with pkgs; [ openssl sqlite ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  nativeBuildInputs = with pkgs; [ perl ];

  meta.mainProgram = "tokscale";
}
