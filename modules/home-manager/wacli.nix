{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.wacli;
  fishEnable = config.programs.fish.enable or false;
in
{
  options.programs.wacli = {
    enable = lib.mkEnableOption "the wacli WhatsApp CLI";

    enableFishIntegration = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "fish"
          "bash"
          "zsh"
        ]
      );
      default = lib.mkDefault (if fishEnable then "fish" else null);
      description = ''
        Shell to install wacli completions for. Set to `null` to disable.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.wacli ];

    config = lib.mkIf (cfg.enableFishIntegration == "fish") {
      xdg.configFile."fish/completions/wacli.fish".source =
        pkgs.runCommand "wacli-fish-completion" { buildInputs = [ pkgs.wacli ]; }
          ''
            ${pkgs.wacli}/bin/wacli completion fish > $out
          '';
    };

    config = lib.mkIf (cfg.enableFishIntegration == "bash") {
      xdg.configFile."bash/completions/wacli".source =
        pkgs.runCommand "wacli-bash-completion" { buildInputs = [ pkgs.wacli ]; }
          ''
            ${pkgs.wacli}/bin/wacli completion bash > $out
          '';
    };

    config = lib.mkIf (cfg.enableFishIntegration == "zsh") {
      xdg.configFile."zsh/completions/_wacli".source =
        pkgs.runCommand "wacli-zsh-completion" { buildInputs = [ pkgs.wacli ]; }
          ''
            ${pkgs.wacli}/bin/wacli completion zsh > $out
          '';
    };
  };
}
