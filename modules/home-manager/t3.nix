{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.t3;
  fishEnable = config.programs.fish.enable or false;
in
{
  options.programs.t3 = {
    enable = lib.mkEnableOption "the t3 CLI";

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
        Shell to install t3 completions for. Set to `null` to disable.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.t3 ];

    config = lib.mkIf (cfg.enableFishIntegration == "fish") {
      xdg.configFile."fish/completions/t3.fish".source =
        pkgs.runCommand "t3-fish-completion" { buildInputs = [ pkgs.t3 ]; }
          ''
            ${pkgs.t3}/bin/t3 --completions fish > $out
          '';
    };

    config = lib.mkIf (cfg.enableFishIntegration == "bash") {
      xdg.configFile."bash/completions/t3".source =
        pkgs.runCommand "t3-bash-completion" { buildInputs = [ pkgs.t3 ]; }
          ''
            ${pkgs.t3}/bin/t3 --completions bash > $out
          '';
    };

    config = lib.mkIf (cfg.enableFishIntegration == "zsh") {
      xdg.configFile."zsh/completions/_t3".source =
        pkgs.runCommand "t3-zsh-completion" { buildInputs = [ pkgs.t3 ]; }
          ''
            ${pkgs.t3}/bin/t3 --completions zsh > $out
          '';
    };
  };
}
