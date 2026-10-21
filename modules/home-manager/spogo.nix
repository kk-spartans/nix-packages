{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.spogo;
  fishEnable = config.programs.fish.enable or false;
in
{
  options.programs.spogo = {
    enable = lib.mkEnableOption "the spogo Google-search CLI";

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
        Shell to install spogo completions for. Set to `null` to disable.
      '';
    };
  };

  config =
    lib.mkIf cfg.enable {
      home.packages = [ pkgs.spogo ];
    }
    // lib.mkIf (cfg.enableFishIntegration == "fish") {
      xdg.configFile."fish/completions/spogo.fish".source =
        pkgs.runCommand "spogo-fish-completion" { buildInputs = [ pkgs.spogo ]; }
          ''
            ${pkgs.spogo}/bin/spogo completion fish > $out
          '';
    }
    // lib.mkIf (cfg.enableFishIntegration == "bash") {
      xdg.configFile."bash/completions/spogo".source =
        pkgs.runCommand "spogo-bash-completion" { buildInputs = [ pkgs.spogo ]; }
          ''
            ${pkgs.spogo}/bin/spogo completion bash > $out
          '';
    }
    // lib.mkIf (cfg.enableFishIntegration == "zsh") {
      xdg.configFile."zsh/completions/_spogo".source =
        pkgs.runCommand "spogo-zsh-completion" { buildInputs = [ pkgs.spogo ]; }
          ''
            ${pkgs.spogo}/bin/spogo completion zsh > $out
          '';
    };
}
