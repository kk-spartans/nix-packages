{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "tokscale";
  version = "4.17.0";

  src = pkgs.fetchurl {
    url = "https://github.com/junhoyeo/tokscale/archive/v${version}.tar.gz";
    hash = "sha256-6qUmkJHYNl3yfeNCAp1YahuzgGsgV1B3zAsr8Dm1frw=";
  };

  cargoHash = "sha256-sJ9sSDP5AYEbRwZMEawNQZMC4/z91PfTqx6beOqVO28=";

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
