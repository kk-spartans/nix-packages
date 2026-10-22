{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.spogo;

  completion = shell: pkgs.runCommand "spogo-${shell}-completion" { } ''
    ${lib.getExe pkgs.spogo} completion ${shell} > $out
  '';
in
{
  options.programs.spogo = {
    enable = lib.mkEnableOption "the spogo Google-search CLI";

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.fish.enable;
      defaultText = lib.literalExpression "config.programs.fish.enable";
      description = "Install fish shell completions for `spogo`.";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.bash.enable;
      defaultText = lib.literalExpression "config.programs.bash.enable";
      description = "Install bash shell completions for `spogo`.";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.zsh.enable;
      defaultText = lib.literalExpression "config.programs.zsh.enable";
      description = "Install zsh shell completions for `spogo`.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ pkgs.spogo ];
    })

    (lib.mkIf (cfg.enable && cfg.enableFishIntegration) {
      xdg.configFile."fish/completions/spogo.fish".source = completion "fish";
    })

    (lib.mkIf (cfg.enable && cfg.enableBashIntegration) {
      xdg.dataFile."bash-completion/completions/spogo".source = completion "bash";
    })

    (lib.mkIf (cfg.enable && cfg.enableZshIntegration) {
      xdg.configFile."zsh/completions/_spogo".source = completion "zsh";
      programs.zsh.initContent = lib.mkAfter ''
        fpath+=(${config.xdg.configHome}/zsh/completions)
      '';
    })
  ];
}
