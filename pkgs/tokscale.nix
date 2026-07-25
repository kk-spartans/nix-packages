{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "tokscale";
  version = "4.6.1";

  src = pkgs.fetchurl {
    url = "https://github.com/junhoyeo/tokscale/archive/v${version}.tar.gz";
    hash = "sha256-qmL/I/0Cpua04UYJagur6y+dN9gTlvQFrixTpyxrpVE=";
  };

  cargoHash = "sha256-8kkd2VhYAa0l9r7Uub4iLhhdss3TtUbbFM2QUhwC1D8=";

  doCheck = false;

  buildInputs = with pkgs; [ openssl sqlite ] ++ lib.optionals stdenv.isDarwin [ libiconv ];

  nativeBuildInputs = with pkgs; [ perl ];

  meta.mainProgram = "tokscale";
}
