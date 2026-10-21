{ pkgs }:
let
  go = pkgs.go_1_27.overrideAttrs (
    finalAttrs: _: {
      version = "1.27.3";
      src = pkgs.fetchurl {
        url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
        hash = "sha256-bndJA1zzYPBrJXXRYup535/ajvZxiJ5cN1+OUHd/Jrs=";
      };
    }
  );
in
(pkgs.buildGoModule.override { inherit go; }) {
  pname = "discrawl";
  version = "unstable";

  src = pkgs.fetchFromGitHub {
    owner = "openclaw";
    repo = "discrawl";
    rev = "bf709e1be4db407f914776fe2e6429464f77cc8f";
    hash = "sha256-3AoyG6Wf4/T60TFdZQL0S/nn4ncdrWqylDpgefugrdg=";
  };

  subPackages = [ "cmd/discrawl" ];
  vendorHash = "sha256-AiWEkdwkfaox3IGAq99hNDpxTZ3S6c/CGEbbdTnDX8I=";

  # Upstream resolves the version from this linker var and falls back to
  # "devel"; without it `discrawl --version` prints "devel".
  ldflags = [ "-X github.com/openclaw/discrawl/internal/cli.version=unstable-bf709e1" ];
}
