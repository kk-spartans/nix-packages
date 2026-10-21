{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "tokscale";
  version = "4.20.0";

  src = pkgs.fetchurl {
    url = "https://github.com/junhoyeo/tokscale/archive/v${version}.tar.gz";
    hash = "sha256-czds3eZSaNGN5dMZ2MrUFtM3AQEgEoT1DVc0MAWNxTM=";
  };

  cargoHash = "sha256-HgjabmTqUQQ2Nq7ngpa6opdRi5XGZVDpLRIFCNWjI38=";

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
