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

    callPkg = system: name: import ./pkgs/${name}.nix {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
  in {
    packages = forAllSystems (system: {
      spogo = callPkg system "spogo";
      fkill = callPkg system "fkill";
      tokscale = callPkg system "tokscale";
      wacli = callPkg system "wacli";
      discrawl = callPkg system "discrawl";
      gogcli = callPkg system "gogcli";
      hf = callPkg system "hf";
      ocrmypdf = callPkg system "ocrmypdf";
      agent-browser-bin = callPkg system "agent-browser-bin";
      pixie-sddm = callPkg system "pixie-sddm";
      aw-watcher-lastfm = callPkg system "aw-watcher-lastfm";
    });
  };
}
