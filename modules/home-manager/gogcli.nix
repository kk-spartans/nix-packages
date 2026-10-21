{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gogcli;
  fishEnable = config.programs.fish.enable or false;
in
{
  options.programs.gogcli = {
    enable = lib.mkEnableOption "the gogcli (gog) Google Workspace CLI";

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
        Shell to install gog completions for. Set to `null` to disable.
      '';
    };
  };

  config =
    lib.mkIf cfg.enable {
      home.packages = [ pkgs.gogcli ];
    }
    // lib.mkIf (cfg.enableFishIntegration == "fish") {
      xdg.configFile."fish/completions/gog.fish".source =
        pkgs.runCommand "gog-fish-completion" { buildInputs = [ pkgs.gogcli ]; }
          ''
            ${pkgs.gogcli}/bin/gog completion fish > $out
          '';
    }
    // lib.mkIf (cfg.enableFishIntegration == "bash") {
      xdg.configFile."bash/completions/gog".source =
        pkgs.runCommand "gog-bash-completion" { buildInputs = [ pkgs.gogcli ]; }
          ''
            ${pkgs.gogcli}/bin/gog completion bash > $out
          '';
    }
    // lib.mkIf (cfg.enableFishIntegration == "zsh") {
      xdg.configFile."zsh/completions/_gog".source =
        pkgs.runCommand "gog-zsh-completion" { buildInputs = [ pkgs.gogcli ]; }
          ''
            ${pkgs.gogcli}/bin/gog completion zsh > $out
          '';
    };
}
