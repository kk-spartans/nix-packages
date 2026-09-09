{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.discord-cli-sync;
in
{
  options.services.discord-cli-sync = {
    enable = lib.mkEnableOption "discord dc sync-all systemd user timer (runs every minute)";

    package = lib.mkPackageOption pkgs "discord-cli" { };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Extra args passed to discord dc sync-all (e.g. -n 500).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.discord-cli-sync = {
      Unit.Description = "discord dc sync-all";
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe cfg.package} dc sync-all ${lib.escapeShellArgs cfg.extraArgs}";
      };
    };

    systemd.user.timers.discord-cli-sync = {
      Unit.Description = "Run discord dc sync-all every minute";
      Timer = {
        OnCalendar = "minutely";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
