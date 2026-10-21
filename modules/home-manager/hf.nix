{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hf;
  fishEnable = config.programs.fish.enable or false;
in
{
  options.programs.hf = {
    enable = lib.mkEnableOption "the hf Hugging Face CLI";

    enableFishIntegration = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "fish" ]);
      default = lib.mkDefault (if fishEnable then "fish" else null);
      description = ''
        Shell to install hf completions for. Set to `null` to disable.
      '';
    };
  };

  config =
    lib.mkIf cfg.enable {
      home.packages = [ pkgs.hf ];
    }
    // lib.mkIf (cfg.enableFishIntegration == "fish") {
      xdg.configFile."fish/completions/hf.fish".source =
        pkgs.runCommand "hf-fish-completion" { buildInputs = [ pkgs.hf ]; }
          ''
            ${pkgs.hf}/bin/hf --show-completion fish > $out
          '';
    };
}
