{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "tokscale";
  version = "4.21.0";

  src = pkgs.fetchurl {
    url = "https://github.com/junhoyeo/tokscale/archive/v${version}.tar.gz";
    hash = "sha256-eAHi7tYdCWCWAcEuB1LdcAJhU0wWub2t10sOc/937Z4=";
  };

  cargoHash = "sha256-jK8SbBFjCTyApzxbqh610Pld8hjJgNsVCg0y2A6wqS4=";

  doCheck = false;

  buildInputs =
    with pkgs;
    [
      openssl
      sqlite
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  nativeBuildInputs = with pkgs; [ perl ];

  meta.mainProgram = "tokscale";
}
