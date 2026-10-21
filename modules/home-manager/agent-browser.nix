{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
let
  cfg = config.programs.agent-browser;
in
{
  options.programs.agent-browser = {
    enable = lib.mkEnableOption "the agent-browser CLI";

    skills = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the upstream agent-browser skill from vercel-labs/agent-browser.";
    };
  };

  config =
    lib.mkIf cfg.enable {
      home.packages = [ pkgs.agent-browser ];
    }
    // lib.mkIf (cfg.enable && cfg.skills && config.programs ? agent-skills) {
      programs.agent-skills = {
        sources.agent-browser = {
          path = pkgs.fetchFromGitHub {
            owner = "vercel-labs";
            repo = "agent-browser";
            rev = "82eadcee41240b1c8477870f846bc8528e77a8a6";
            hash = "sha256-NbIl24zbSqAbKbZcT5mGGgaUmT1FIwnUMMkMx+za0DU=";
          };
          subdir = "skills";
        };
        skills.enable = [ "agent-browser" ];
      };
    }
    // lib.mkIf cfg.enable {
      home.file.".agent-browser/config.json".text = ''
        {
          "$schema": "https://agent-browser.dev/schema.json",
          "profile": "~/.agent-browser/browser-data",
          "headed": true
        }
      '';
    };
}
