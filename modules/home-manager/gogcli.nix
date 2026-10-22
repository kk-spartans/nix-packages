{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gogcli;

  # The binary is installed as `gog`, not `gogcli`.
  completion = shell: pkgs.runCommand "gog-${shell}-completion" { } ''
    ${lib.getExe' pkgs.gogcli "gog"} completion ${shell} > $out
  '';
in
{
  options.programs.gogcli = {
    enable = lib.mkEnableOption "the gogcli (gog) Google Workspace CLI";

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.fish.enable;
      defaultText = lib.literalExpression "config.programs.fish.enable";
      description = "Install fish shell completions for `gog`.";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.bash.enable;
      defaultText = lib.literalExpression "config.programs.bash.enable";
      description = "Install bash shell completions for `gog`.";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.zsh.enable;
      defaultText = lib.literalExpression "config.programs.zsh.enable";
      description = "Install zsh shell completions for `gog`.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ pkgs.gogcli ];
    })

    (lib.mkIf (cfg.enable && cfg.enableFishIntegration) {
      xdg.configFile."fish/completions/gog.fish".source = completion "fish";
    })

    (lib.mkIf (cfg.enable && cfg.enableBashIntegration) {
      xdg.dataFile."bash-completion/completions/gog".source = completion "bash";
    })

    (lib.mkIf (cfg.enable && cfg.enableZshIntegration) {
      xdg.configFile."zsh/completions/_gog".source = completion "zsh";
      programs.zsh.initContent = lib.mkAfter ''
        fpath+=(${config.xdg.configHome}/zsh/completions)
      '';
    })
  ];
}
