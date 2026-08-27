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
      description = "Extra args passed to wacli sync (e.g. --refresh-groups). --follow is always added for service.";
    };

    interval = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        If set, run as timer instead of long-running --follow service.
        Value is systemd OnCalendar (e.g. "*:0/30" for every 30min, overridable).
        When null (default), runs `wacli sync --follow` continuously.
      '';
      example = "*:0/30";
    };
  };

  config = lib.mkIf cfg.enable (
    if cfg.interval == null then
      {
        systemd.user.services.wacli-sync = {
          Unit.Description = "wacli sync --follow";
          Service = {
            ExecStart = "${lib.getExe cfg.package} sync --follow ${lib.escapeShellArgs cfg.extraArgs}";
            Restart = "always";
            RestartSec = "10s";
          };
          Install.WantedBy = [ "default.target" ];
        };
      }
    else
      {
        systemd.user.services.wacli-sync = {
          Unit.Description = "wacli sync (timer)";
          Service = {
            Type = "oneshot";
            ExecStart = "${lib.getExe cfg.package} sync --once ${lib.escapeShellArgs cfg.extraArgs}";
          };
        };
        systemd.user.timers.wacli-sync = {
          Unit.Description = "wacli sync timer";
          Timer.OnCalendar = cfg.interval;
          Timer.Persistent = true;
          Install.WantedBy = [ "timers.target" ];
        };
      }
  );
}
