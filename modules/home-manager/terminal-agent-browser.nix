{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.terminal-agent-browser;
in
{
  options.programs.terminal-agent-browser = {
    enable = lib.mkEnableOption "per-herdr-tab terminal-browser agent control (`terminal-agent-browser`)";

    package = lib.mkPackageOption pkgs "terminal-agent-browser" { };

    skill = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Install the terminal-agent-browser skill to
          ~/.agents/skills/terminal-agent-browser/SKILL.md.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = "programs.terminal-agent-browser is Linux-only (terminal-browser ships Linux binaries).";
      }
    ];

    home.packages = [ cfg.package ];

    home.file = lib.mkIf cfg.skill.enable {
      ".agents/skills/terminal-agent-browser/SKILL.md".source = ../../skills/terminal-agent-browser/SKILL.md;
    };
  };
}
