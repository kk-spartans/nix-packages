{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gogcli;
  fishEnable = config.programs.fish.enable or false;
  bashEnable = config.programs.bash.enable or false;
  zshEnable = config.programs.zsh.enable or false;
in
{
  options.programs.gogcli = {
    enable = lib.mkEnableOption "the gogcli (gog) Google Workspace CLI";

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = fishEnable;
      description = ''
        Install shell completions for fish.
      '';
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = bashEnable;
      description = ''
        Install shell completions for bash.
      '';
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = zshEnable;
      description = ''
        Install shell completions for zsh.
      '';
    };
  };

  config =
    lib.mkIf cfg.enable {
      home.packages = [ pkgs.gogcli ];
    }
    // lib.mkIf (cfg.enable && cfg.enableFishIntegration) {
      xdg.configFile."fish/completions/gog.fish".source =
        pkgs.runCommand "gog-fish-completion" { buildInputs = [ pkgs.gogcli ]; }
          ''
            ${pkgs.gogcli}/bin/gog completion fish > $out
          '';
    }
    // lib.mkIf (cfg.enable && cfg.enableBashIntegration) {
      xdg.configFile."bash/completions/gog".source =
        pkgs.runCommand "gog-bash-completion" { buildInputs = [ pkgs.gogcli ]; }
          ''
            ${pkgs.gogcli}/bin/gog completion bash > $out
          '';
    }
    // lib.mkIf (cfg.enable && cfg.enableZshIntegration) {
      xdg.configFile."zsh/completions/_gog".source =
        pkgs.runCommand "gog-zsh-completion" { buildInputs = [ pkgs.gogcli ]; }
          ''
            ${pkgs.gogcli}/bin/gog completion zsh > $out
          '';
    };
}
