{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.wacli;
  fishEnable = config.programs.fish.enable or false;
  bashEnable = config.programs.bash.enable or false;
  zshEnable = config.programs.zsh.enable or false;
in
{
  options.programs.wacli = {
    enable = lib.mkEnableOption "the wacli WhatsApp CLI";

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
      home.packages = [ pkgs.wacli ];
    }
    // lib.mkIf (cfg.enable && cfg.enableFishIntegration) {
      xdg.configFile."fish/completions/wacli.fish".source =
        pkgs.runCommand "wacli-fish-completion" { buildInputs = [ pkgs.wacli ]; }
          ''
            ${pkgs.wacli}/bin/wacli completion fish > $out
          '';
    }
    // lib.mkIf (cfg.enable && cfg.enableBashIntegration) {
      xdg.configFile."bash/completions/wacli".source =
        pkgs.runCommand "wacli-bash-completion" { buildInputs = [ pkgs.wacli ]; }
          ''
            ${pkgs.wacli}/bin/wacli completion bash > $out
          '';
    }
    // lib.mkIf (cfg.enable && cfg.enableZshIntegration) {
      xdg.configFile."zsh/completions/_wacli".source =
        pkgs.runCommand "wacli-zsh-completion" { buildInputs = [ pkgs.wacli ]; }
          ''
            ${pkgs.wacli}/bin/wacli completion zsh > $out
          '';
    };
}
