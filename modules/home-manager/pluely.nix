{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pluely;
in
{
  options.programs.pluely = {
    enable = lib.mkEnableOption "Pluely, a privacy-first AI assistant";

    package = lib.mkPackageOption pkgs "pluely" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
