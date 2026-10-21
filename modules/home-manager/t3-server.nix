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

  # t3's device hub (LocalDeviceHost.androidSdk) resolves the SDK root from
  # ANDROID_HOME / ANDROID_SDK_ROOT, then requires `platform-tools/adb`,
  # `emulator/emulator` and `cmdline-tools/latest/bin/avdmanager` to exist
  # under that root. Nix's pkgs.androidsdk lays the command-line tools out
  # under a versioned dir (`cmdline-tools/22.0`), never `latest`, so we point
  # ANDROID_HOME at a symlink farm that adds the `latest` entry t3 looks for.
  # Without it t3 reports Android as unavailable and the device panel shows
  # "No simulators or emulators were found".
  androidSdk = pkgs.runCommand "androidsdk-devicehub" { } ''
    sdk=${pkgs.androidsdk}/libexec/android-sdk
    mkdir -p $out/cmdline-tools
    for entry in "$sdk"/*; do
      base=$(basename "$entry")
      if [ "$base" = cmdline-tools ]; then
        continue
      fi
      ln -s "$entry" "$out/$base"
    done
    for entry in "$sdk"/cmdline-tools/*; do
      ln -s "$entry" "$out/cmdline-tools/$(basename "$entry")"
      ln -s "$entry" "$out/cmdline-tools/latest"
    done
  '';

  servicePath = lib.makeBinPath (
    [
      pkgs.coreutils
      pkgs.gnugrep
    ]
    ++ lib.optionals tailscaleEnabled [ pkgs.tailscale ]
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
        # `tailscale serve` requires our user to be the tailscale operator.
        # That assignment typically happens in a system-level oneshot shortly
        # after tailscaled comes up, so wait for it explicitly instead of
        # racing it (exit 1 -> systemd retries).
        opReady=""
        for _ in $(seq 1 ${toString cfg.tailscale.waitTimeout}); do
          if ${lib.getExe pkgs.tailscale} debug prefs 2>/dev/null | grep -q '"OperatorUser": "${config.home.username}"'; then
            opReady=1
            break
          fi
          sleep 1
        done

        if [[ -z "$opReady" ]]; then
          echo "t3-server: ${config.home.username} is not the tailscale operator after ${toString cfg.tailscale.waitTimeout}s." >&2
          echo "t3-server: run 'sudo tailscale set --operator ${config.home.username}' or add a NixOS oneshot that does." >&2
          exit 1
        fi

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

    deviceHub = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Wire t3's device hub up for Android emulators. Enabling this:

        - installs the full Android SDK (`pkgs.androidsdk`) into `home.packages`
          (complete SDK: cmdline-tools, platform-tools, build-tools, platforms,
          emulator, system images and the NDK, not the lightweight
          `android-tools` adb/fastboot shim);
        - exports `ANDROID_HOME`/`ANDROID_SDK_ROOT` (in the t3-server systemd
          unit, `home.sessionVariables`, and to t3 itself) pointing at an SDK
          root that t3 accepts — nix ships the command-line tools as
          `cmdline-tools/<version>` while t3 hardcodes
          `cmdline-tools/latest/bin/avdmanager`, so we point at a symlink farm
          that adds `latest`;
        - creates the AVD in `deviceHubAvd` on activation if it does not exist,
          so the Device panel lists an emulator instead of
          "No simulators or emulators were found".

        The SDK is unfree: set `nixpkgs.config.android_sdk.accept_license = true;`
        and enable unfree packages (`allowUnfree = true` or a matching
        `allowUnfreePredicate`), otherwise evaluation fails.
      '';
    };

    deviceHubAvd = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "t3-pixel";
        description = "Name of the Android Virtual Device created on activation.";
      };

      device = lib.mkOption {
        type = lib.types.str;
        default = "pixel_7";
        description = "Hardware profile passed to `avdmanager -d`.";
      };

      image = lib.mkOption {
        type = lib.types.str;
        default = "system-images;android-36;google_apis;x86_64";
        description = ''
          System image package passed to `avdmanager -k`. Must be one of the
          images bundled in `pkgs.androidsdk`.
        '';
      };
    };

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

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = (config.programs.fish.enable or false);
      description = ''
        Install fish shell completions for the `t3` CLI.
      '';
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = (config.programs.bash.enable or false);
      description = ''
        Install bash shell completions for the `t3` CLI.
      '';
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = (config.programs.zsh.enable or false);
      description = ''
        Install zsh shell completions for the `t3` CLI.
      '';
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
      {
        assertion = !cfg.deviceHub || (pkgs.config.android_sdk.accept_license or false);
        message = ''
          services.t3-server.deviceHub installs pkgs.androidsdk, which is unfree
          and requires the SDK license to be accepted. Add to your nixpkgs config:
            nixpkgs.config.android_sdk.accept_license = true;
        '';
      }
      {
        assertion =
          !cfg.deviceHub
          || (pkgs.config.allowUnfree or false)
          || (pkgs.config.allowUnfreePredicate or null) != null;
        message = ''
          services.t3-server.deviceHub installs pkgs.androidsdk, which is unfree.
          Enable unfree packages:
            nixpkgs.config.allowUnfree = true;
          or an allowUnfreePredicate that permits `androidsdk`.
        '';
      }
      {
        assertion =
          !cfg.deviceHub
          || (
            (!(lib.hasInfix "x86_64" cfg.deviceHubAvd.image) || pkgs.stdenv.hostPlatform.isx86_64)
            && (!(lib.hasInfix "arm64" cfg.deviceHubAvd.image) || pkgs.stdenv.hostPlatform.isAarch64)
          );
        message = ''
          services.t3-server.deviceHub: the configured AVD image
            ${cfg.deviceHubAvd.image}
          does not match this host (${pkgs.stdenv.hostPlatform.system}). The
          emulator cannot accelerate a cross-architecture guest, so the AVD
          would be listed but fail to boot. Pick a matching image via
          services.t3-server.deviceHubAvd.image.
        '';
      }
    ];

    warnings =
      lib.optional (tailscaleEnabled && cfg.tailscale.serve) ''
        services.t3-server.tailscale.serve needs your user configured as tailscale operator:
          sudo tailscale set --operator ${config.home.username}
        Otherwise `tailscale serve` fails inside the service.
      ''
      ++ lib.optional cfg.deviceHub ''
        services.t3-server.deviceHub: the Android emulator needs /dev/kvm access,
        which a home-manager module cannot grant (it is a NixOS-level setting).
        On NixOS add your user to the kvm group:
          users.users.${config.home.username}.extraGroups = [ "kvm" ];
        Without it the AVD is listed by t3 but the emulator falls back to
        extremely slow software emulation (or fails to start).
      '';

    home.packages =
      lib.optionals cfg.enable [ cfg.package ] ++ lib.optionals cfg.deviceHub [ pkgs.androidsdk ];

    # Shell completions for the `t3` CLI.
    xdg.configFile = lib.listToAttrs (
      lib.optionals cfg.enableFishIntegration [
        {
          name = "fish/completions/t3.fish";
          value = {
            source = pkgs.runCommand "t3-fish-completion" { buildInputs = [ t3Package ]; } ''
              ${t3Package}/bin/t3 --completions fish > $out
            '';
          };
        }
      ]
      ++ lib.optionals cfg.enableBashIntegration [
        {
          name = "bash/completions/t3";
          value = {
            source = pkgs.runCommand "t3-bash-completion" { buildInputs = [ t3Package ]; } ''
              ${t3Package}/bin/t3 --completions bash > $out
            '';
          };
        }
      ]
      ++ lib.optionals cfg.enableZshIntegration [
        {
          name = "zsh/completions/_t3";
          value = {
            source = pkgs.runCommand "t3-zsh-completion" { buildInputs = [ t3Package ]; } ''
              ${t3Package}/bin/t3 --completions zsh > $out
            '';
          };
        }
      ]
    );

    home.sessionVariables = lib.mkIf cfg.deviceHub {
      ANDROID_HOME = "${androidSdk}";
      ANDROID_SDK_ROOT = "${androidSdk}";
    };

    # Create the emulator AVD once so t3's Device panel has something to list.
    # Idempotent: skipped when the AVD already exists. Never fails activation
    # (avdmanager is best-effort; the panel degrades to the empty state).
    home.activation.t3-device-hub-avd = lib.mkIf cfg.deviceHub (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        export ANDROID_HOME=${lib.escapeShellArg "${androidSdk}"}
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
        export ANDROID_AVD_HOME=${lib.escapeShellArg "${config.home.homeDirectory}/.android/avd"}
        if ! "$ANDROID_HOME/emulator/emulator" -list-avds 2>/dev/null | ${pkgs.gnugrep}/bin/grep -qx ${lib.escapeShellArg cfg.deviceHubAvd.name}; then
          ${pkgs.coreutils}/bin/mkdir -p "$ANDROID_AVD_HOME"
          echo no | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd \
            -n ${lib.escapeShellArg cfg.deviceHubAvd.name} \
            -k ${lib.escapeShellArg cfg.deviceHubAvd.image} \
            -d ${lib.escapeShellArg cfg.deviceHubAvd.device} \
            --force || true
        fi
      ''
    );

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
        # Inherit user's full PATH so tools from nix-profile / home.packages (spogo etc.) are visible.
        # systemd user services don't inherit the login shell PATH, so we explicitly add the usual profile dirs.
        Environment = [
          "PATH=${servicePath}${lib.optionalString cfg.deviceHub ":${androidSdk}/platform-tools:${androidSdk}/emulator"}:${config.home.homeDirectory}/.nix-profile/bin:${config.home.homeDirectory}/.local/state/nix/profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"
        ]
        ++ lib.optionals cfg.deviceHub [
          "ANDROID_HOME=${androidSdk}"
          "ANDROID_SDK_ROOT=${androidSdk}"
          "ANDROID_AVD_HOME=${config.home.homeDirectory}/.android/avd"
        ];
        # Light touch on purpose: t3 spawns interactive agent harnesses
        # (pty, git, network); aggressive namespacing breaks them.
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
