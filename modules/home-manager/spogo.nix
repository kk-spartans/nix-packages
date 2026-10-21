{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.spogo;
  fishEnable = config.programs.fish.enable or false;
  bashEnable = config.programs.bash.enable or false;
  zshEnable = config.programs.zsh.enable or false;
in
{
  options.programs.spogo = {
    enable = lib.mkEnableOption "the spogo Google-search CLI";

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
      home.packages = [ pkgs.spogo ];
    }
    // lib.mkIf (cfg.enable && cfg.enableFishIntegration) {
      xdg.configFile."fish/completions/spogo.fish".source =
        pkgs.runCommand "spogo-fish-completion" { buildInputs = [ pkgs.spogo ]; }
          ''
            ${pkgs.spogo}/bin/spogo completion fish > $out
          '';
    }
    // lib.mkIf (cfg.enable && cfg.enableBashIntegration) {
      xdg.configFile."bash/completions/spogo".source =
        pkgs.runCommand "spogo-bash-completion" { buildInputs = [ pkgs.spogo ]; }
          ''
            ${pkgs.spogo}/bin/spogo completion bash > $out
          '';
    }
    // lib.mkIf (cfg.enable && cfg.enableZshIntegration) {
      xdg.configFile."zsh/completions/_spogo".source =
        pkgs.runCommand "spogo-zsh-completion" { buildInputs = [ pkgs.spogo ]; }
          ''
            ${pkgs.spogo}/bin/spogo completion zsh > $out
          '';
    };
}
