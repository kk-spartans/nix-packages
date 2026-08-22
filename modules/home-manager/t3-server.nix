{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.t3-server;

  # Harness toggles understood by pkgs.t3code's override args.
  knownHarnesses = [
    "enableAzureDevOps"
    "enableBitbucket"
    "enableClaude"
    "enableCodex"
    "enableCursor"
    "enableCursorCli"
    "enableGitHub"
    "enableGit"
    "enableGitLab"
    "enableJujutsu"
    "enableOpencode"
  ];

  unknownHarnesses = lib.subtractLists knownHarnesses (builtins.attrNames cfg.harnesses);

  t3Package =
    if cfg.harnesses == { } then
      cfg.package
    else
      assert lib.assertMsg (unknownHarnesses == [ ])
        "services.t3-server.harnesses: unknown key(s): ${lib.concatStringsSep ", " unknownHarnesses}. Valid keys: ${lib.concatStringsSep ", " knownHarnesses}";
      cfg.package.override cfg.harnesses;

  tailscaleEnabled = cfg.tailscale.enable;

  servicePath = lib.makeBinPath (
    [ pkgs.coreutils ] ++ lib.optionals tailscaleEnabled [ pkgs.tailscale ]
  );

  startScript = pkgs.writeShellScript "t3-server-start" ''
    set -euo pipefail

    host="${cfg.host}"
    tailscaleArgs=()

    ${lib.optionalString tailscaleEnabled ''
      # Wait for tailscaled to come up; user units cannot order against the
      # system-level tailscaled.service directly.
      ready=""
      for _ in $(seq 1 ${toString cfg.tailscale.waitTimeout}); do
        if ${lib.getExe pkgs.tailscale} status >/dev/null 2>&1; then
          ready=1
          break
        fi
        sleep 1
      done

      if [[ -z "$ready" ]]; then
        echo "t3-server: tailscale did not become ready within ${toString cfg.tailscale.waitTimeout}s" >&2
        exit 1
      fi

      ${lib.optionalString cfg.tailscale.bindIp ''
        host="$(${lib.getExe pkgs.tailscale} ip -4 | head -n1)"
        if [[ -z "$host" ]]; then
          echo "t3-server: no tailnet IPv4 address available" >&2
          exit 1
        fi
      ''}

      ${lib.optionalString cfg.tailscale.serve ''
        tailscaleArgs+=(--tailscale-serve)
        ${lib.optionalString (
          cfg.tailscale.servePort != null
        ) "tailscaleArgs+=(--tailscale-serve-port ${toString cfg.tailscale.servePort})"}
      ''}
    ''}

    exec ${lib.getExe' t3Package "t3"} serve \
      --host "$host" \
      --port ${toString cfg.port} \
      "''${tailscaleArgs[@]}" \
      ${lib.escapeShellArgs cfg.extraArgs}
  '';
in
{
  options.services.t3-server = {
    enable = lib.mkEnableOption "T3 Code headless server (systemd user service)";

    package = lib.mkPackageOption pkgs "t3code" { };

    harnesses = lib.mkOption {
      type = with lib.types; attrsOf bool;
      default = { };
      description = ''
        Extra agent harnesses to put on PATH for t3, applied as overrides on
        `pkgs.t3code`. Keys map to upstream override args, e.g.
        `{ claude = ... }` is invalid; use `{ enableClaude = true; }`.
        Defaults (codex, git, gh) stay on unless explicitly disabled.
      '';
      example = {
        enableClaude = true;
        enableOpencode = true;
        enableJujutsu = true;
      };
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Bind address for the server. Ignored when
        `services.t3-server.tailscale.bindIp` is enabled, in which case the
        tailnet IPv4 is resolved at startup instead.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3773;
      description = "TCP port to listen on. Pinned explicitly so restarts don't drift ports.";
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Extra arguments passed to `t3 serve`.";
      example = [ "--log-ws-events" ];
    };

    tailscale = {
      enable = lib.mkEnableOption ''
        Tailscale integration: waits for tailscaled before starting and puts
        `tailscale` on the service PATH.
      '';

      bindIp = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Bind directly to the tailnet IPv4 address (plain HTTP over
          WireGuard). Mutually exclusive with `tailscale.serve`.
        '';
      };

      serve = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Use t3's built-in `--tailscale-serve` flag to publish the local
          server over HTTPS on the tailnet via `tailscale serve`. Requires
          binding to loopback and that your user is a tailscale operator
          (`sudo tailscale set --operator <user>`).
        '';
      };

      servePort = lib.mkOption {
        type = with lib.types; nullOr port;
        default = 443;
        description = "HTTPS port used for the tailscale serve proxy. `null` uses t3's default.";
      };

      waitTimeout = lib.mkOption {
        type = lib.types.ints.positive;
        default = 60;
        description = "Seconds to wait for tailscaled readiness before failing.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.tailscale.serve || !cfg.tailscale.bindIp;
        message = "services.t3-server: tailscale.serve and tailscale.bindIp are mutually exclusive (serve proxies to 127.0.0.1).";
      }
      {
        assertion = !cfg.tailscale.serve || tailscaleEnabled;
        message = "services.t3-server: tailscale.serve requires tailscale.enable.";
      }
      {
        assertion = !cfg.tailscale.serve || cfg.host == "127.0.0.1";
        message = "services.t3-server: tailscale.serve proxies http://127.0.0.1, so host must be 127.0.0.1.";
      }
    ];

    warnings = lib.optional (tailscaleEnabled && cfg.tailscale.serve) ''
      services.t3-server.tailscale.serve needs your user configured as tailscale operator:
        sudo tailscale set --operator ${config.home.username}
      Otherwise `tailscale serve` fails inside the service.
    '';

    systemd.user.services.t3-server = {
      Unit = {
        Description = "T3 Code headless server";
        After = [ "default.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${startScript}";
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = [ "PATH=${servicePath}" ];
        # Light touch on purpose: t3 spawns interactive agent harnesses
        # (pty, git, network); aggressive namespacing breaks them.
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
