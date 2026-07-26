{
  description = "kk-spartan's custom nixpkgs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=master";
  };

  outputs = { self, nixpkgs, ... }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    overlays = {
      default = final: prev: {
        spogo = import ./pkgs/spogo.nix { pkgs = final; };
        fkill = import ./pkgs/fkill.nix { pkgs = final; };
        tokscale = import ./pkgs/tokscale.nix { pkgs = final; };
        wacli = import ./pkgs/wacli.nix { pkgs = final; };
        discrawl = import ./pkgs/discrawl.nix { pkgs = final; };
        gogcli = import ./pkgs/gogcli.nix { pkgs = final; };
        hf = import ./pkgs/hf.nix { pkgs = final; };
        ocrmypdf = import ./pkgs/ocrmypdf.nix { pkgs = final; };
        agent-browser-bin = import ./pkgs/agent-browser-bin.nix { pkgs = final; };
        pixie-sddm = import ./pkgs/pixie-sddm.nix { pkgs = final; };
        aw-watcher-lastfm = import ./pkgs/aw-watcher-lastfm.nix { pkgs = final; };
      };

      bun-baseline = final: prev: prev.lib.optionalAttrs prev.stdenv.hostPlatform.isx86_64 {
        bun = prev.bun.overrideAttrs (finalAttrs: previousAttrs: {
          src = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${finalAttrs.version}/bun-linux-x64-baseline.zip";
            hash = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
          };

          sourceRoot = "bun-linux-x64-baseline";

          passthru = previousAttrs.passthru // {
            baseline = true;
          };
        });
      };
    };

    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };
    in {
      inherit (pkgs)
        spogo fkill tokscale wacli discrawl gogcli hf ocrmypdf
        agent-browser-bin pixie-sddm aw-watcher-lastfm;
    });
  };
}
