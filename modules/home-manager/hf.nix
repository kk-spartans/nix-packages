{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hf;

  completion = shell: pkgs.runCommand "hf-${shell}-completion" { } ''
    ${lib.getExe pkgs.hf} --show-completion ${shell} > $out
  '';
in
{
  options.programs.hf = {
    enable = lib.mkEnableOption "the hf Hugging Face CLI";

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.fish.enable;
      defaultText = lib.literalExpression "config.programs.fish.enable";
      description = "Install fish shell completions for `hf`.";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.bash.enable;
      defaultText = lib.literalExpression "config.programs.bash.enable";
      description = "Install bash shell completions for `hf`.";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.zsh.enable;
      defaultText = lib.literalExpression "config.programs.zsh.enable";
      description = "Install zsh shell completions for `hf`.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ pkgs.hf ];
    })

    (lib.mkIf (cfg.enable && cfg.enableFishIntegration) {
      xdg.configFile."fish/completions/hf.fish".source = completion "fish";
    })

    (lib.mkIf (cfg.enable && cfg.enableBashIntegration) {
      xdg.dataFile."bash-completion/completions/hf".source = completion "bash";
    })

    (lib.mkIf (cfg.enable && cfg.enableZshIntegration) {
      xdg.configFile."zsh/completions/_hf".source = completion "zsh";
      programs.zsh.initContent = lib.mkAfter ''
        fpath+=(${config.xdg.configHome}/zsh/completions)
      '';
    })
  ];
}
