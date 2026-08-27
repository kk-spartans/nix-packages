{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.wacli-sync;
in
{
  options.services.wacli-sync = {
    enable = lib.mkEnableOption "wacli sync --follow systemd user service (long-running)";

    package = lib.mkPackageOption pkgs "wacli" { };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Extra args passed to wacli sync (e.g. --refresh-groups). --follow is always added.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.wacli-sync = {
      Unit.Description = "wacli sync --follow";
      Service = {
        ExecStart = "${lib.getExe cfg.package} sync --follow ${lib.escapeShellArgs cfg.extraArgs}";
        Restart = "always";
        RestartSec = "10s";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
