{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "tokscale";
  version = "4.18.0";

  src = pkgs.fetchurl {
    url = "https://github.com/junhoyeo/tokscale/archive/v${version}.tar.gz";
    hash = "sha256-JciFT7EYRmDC6D5yDUzuixREaqZhQZeZefEmAt1R/S8=";
  };

  cargoHash = "sha256-0yPl4+UjPJjVoTrsthSGBruog1SXuZTr7vUHlAxPigg=";

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
