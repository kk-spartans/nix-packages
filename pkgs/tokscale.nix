{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "tokscale";
  version = "4.20.1";

  src = pkgs.fetchurl {
    url = "https://github.com/junhoyeo/tokscale/archive/v${version}.tar.gz";
    hash = "sha256-ahmAQ/e468+8v7XkXwt8R3ElxzAPzIJ7VQXeJiHv++g=";
  };

  cargoHash = "sha256-Oh57ILq8GYWMXW5Ok/xhGnALHJx00bD+fmv7qoMU37w=";

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
