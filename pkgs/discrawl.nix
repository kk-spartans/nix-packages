{ pkgs }:
(pkgs.buildGoModule.override { go = pkgs.go_1_27; }) {
  pname = "discrawl";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "0853d40e0525ab4384f906467ef9fce1e9cbdfbb";
    hash = "sha256-pEmH+lk2HAsJZbwNOviuSjHUkOe1zm8KZMUNgKEvmDY=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-2gKVsw3Ek/LmuFEvgoA2pDvTag7DINILt9yZobEMSk4=";
}
