{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hf;
  fishEnable = config.programs.fish.enable or false;
  bashEnable = config.programs.bash.enable or false;
  zshEnable = config.programs.zsh.enable or false;
in
{
  options.programs.hf = {
    enable = lib.mkEnableOption "the hf Hugging Face CLI";

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
      home.packages = [ pkgs.hf ];
    }
    // lib.mkIf (cfg.enable && cfg.enableFishIntegration) {
      xdg.configFile."fish/completions/hf.fish".source =
        pkgs.runCommand "hf-fish-completion" { buildInputs = [ pkgs.hf ]; }
          ''
            ${pkgs.hf}/bin/hf --show-completion fish > $out
          '';
    }
    // lib.mkIf (cfg.enable && cfg.enableBashIntegration) {
      xdg.configFile."bash/completions/hf".source =
        pkgs.runCommand "hf-bash-completion" { buildInputs = [ pkgs.hf ]; }
          ''
            ${pkgs.hf}/bin/hf --show-completion bash > $out
          '';
    }
    // lib.mkIf (cfg.enable && cfg.enableZshIntegration) {
      xdg.configFile."zsh/completions/_hf".source =
        pkgs.runCommand "hf-zsh-completion" { buildInputs = [ pkgs.hf ]; }
          ''
            ${pkgs.hf}/bin/hf --show-completion zsh > $out
          '';
    };
}
