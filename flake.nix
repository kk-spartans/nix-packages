{
  description = "kk-spartan's custom nixpkgs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=master";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      overlays = {
        default =
          final: prev:
          {
            spogo = import ./pkgs/spogo.nix { pkgs = final; };
            fkill = import ./pkgs/fkill.nix { pkgs = final; };
            tokscale = import ./pkgs/tokscale.nix { pkgs = final; };
            wacli = import ./pkgs/wacli.nix { pkgs = final; };
            discrawl = import ./pkgs/discrawl.nix { pkgs = final; };
            gogcli = import ./pkgs/gogcli.nix { pkgs = final; };
            hf = import ./pkgs/hf.nix { pkgs = final; };
            ocrmypdf = import ./pkgs/ocrmypdf.nix { pkgs = final; };
            agent-browser = import ./pkgs/agent-browser.nix { pkgs = final; };
            aw-watcher-lastfm = import ./pkgs/aw-watcher-lastfm.nix { pkgs = final; };
            portless = import ./pkgs/portless.nix { pkgs = final; };
            t3-unwrapped = final.callPackage ./pkgs/t3-unwrapped.nix { };
            t3-nightly-unwrapped = final.callPackage ./pkgs/t3-nightly-unwrapped.nix { };
            t3 = final.callPackage ./pkgs/t3.nix { };
            t3-nightly = final.callPackage ./pkgs/t3.nix {
              pname = "t3-nightly";
              t3-unwrapped = final.t3-nightly-unwrapped;
            };
          }
          // prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
            terminal-browser = import ./pkgs/terminal-browser.nix { pkgs = final; };
          }
          // prev.lib.optionalAttrs (prev.stdenv.hostPlatform.isLinux && prev.stdenv.hostPlatform.isx86_64) {
            t1code = import ./pkgs/t1code.nix { pkgs = final; };
          };
      };

      homeManagerModules = {
        default = import ./modules/home-manager/t3-server.nix;
        t3-server = import ./modules/home-manager/t3-server.nix;
        wacli-sync = import ./modules/home-manager/wacli-sync.nix;
        agent-browser = import ./modules/home-manager/agent-browser.nix;
        spogo = import ./modules/home-manager/spogo.nix;
        gogcli = import ./modules/home-manager/gogcli.nix;
        wacli = import ./modules/home-manager/wacli.nix;
        t3 = import ./modules/home-manager/t3.nix;
        hf = import ./modules/home-manager/hf.nix;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };
        in
        {
          inherit (pkgs)
            spogo
            fkill
            tokscale
            wacli
            discrawl
            gogcli
            hf
            ocrmypdf
            agent-browser
            aw-watcher-lastfm
            portless
            t3
            t3-nightly
            t3-unwrapped
            t3-nightly-unwrapped
            ;
          # Update-only helpers: fixed-output dependency trees nix-update targets.
          fkill-deps = pkgs.callPackage ./pkgs/fkill-deps.nix { };
          portless-deps = pkgs.callPackage ./pkgs/portless-deps.nix { };
          hf-deps = pkgs.callPackage ./pkgs/hf-deps.nix { };
          ocrmypdf-deps = pkgs.callPackage ./pkgs/ocrmypdf-deps.nix { };
        }
        // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          inherit (pkgs) terminal-browser;
          terminal-browser-aarch64 = pkgs.callPackage ./pkgs/terminal-browser-aarch64.nix { };
        }
        // pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64) {
          inherit (pkgs) t1code;
          t1code-deps = pkgs.callPackage ./pkgs/t1code-deps.nix { };
        }
      );
    };
}
