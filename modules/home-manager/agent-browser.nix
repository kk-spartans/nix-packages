{
  config,
  lib,
  options,
  pkgs,
  osConfig ? { },
  ...
}:
let
  cfg = config.programs.agent-browser;

  isMacPro = (osConfig.networking.hostName or "") == "mac-pro";
  isKkSpartans = (osConfig.networking.hostName or "") == "kk-spartans";

  # mac-pro only: drives the persistent real-Chrome service over the tailnet
  # (~/things/docker/browsers on mac-pro: branded google-chrome-stable
  # under Xvfb, profile in ./profile; no ports published on any host — the
  # spartans gateway at https://browsers.services.spartans routes
  # /json/* + /devtools/* to Chrome and everything else to the noVNC UI).
  # Watch the live session at .../vnc.html — same browser the agent drives.
  # Log into Google by hand once in that UI; the agent inherits the
  # persisted session. No license keys. Override with BROWSERS_BASE.
  agent-browser-tailnet = pkgs.writeShellApplication {
    name = "agent-browser";
    runtimeInputs = [
      pkgs.agent-browser
      pkgs.curl
      pkgs.python3
    ];

    text = ''
            set -euo pipefail

            BASE="''${BROWSERS_BASE:-https://browsers.services.spartans}"

            # agent-browser is a static binary with its own CA bundle, so it cannot be
            # taught the gateway's private CA and would refuse the wss:// endpoint.
            # Fetch /json/version over https (curl does trust it) and then dial the
            # plaintext loopback port the cdp-proxy also publishes, which is the same
            # nginx, same Chrome, same session. Override with BROWSERS_WS=... to point
            # somewhere else.
            WS="$(${pkgs.curl}/bin/curl -sf -m 15 "$BASE/json/version" | ${pkgs.python3}/bin/python3 -c '
      import json, os, sys, urllib.parse
      url = json.load(sys.stdin)["webSocketDebuggerUrl"]
      override = os.environ.get("BROWSERS_WS")
      if override:
          print(override + urllib.parse.urlparse(url).path)
      else:
          p = urllib.parse.urlparse(url)
          print("ws://127.0.0.1:9222" + p.path)
      ')"
            if [ -z "$WS" ]; then
              echo "agent-browser: no Chrome reachable via $BASE." >&2
              echo "On mac-pro: cd ~/things/docker/browsers && docker compose up -d" >&2
              echo "Watch it at https://browsers.services.spartans/vnc.html" >&2
              exit 1
            fi

            exec ${pkgs.agent-browser}/bin/agent-browser --cdp "$WS" "$@"
    '';
  };

  # kk-spartans only (local cloak container, pre-027b1a1 behavior): starts
  # its own cloakhq/cloakbrowser container on 127.0.0.1:9222 instead of
  # the tailnet Chrome.
  agent-browser-cloak = pkgs.writeShellApplication {
    name = "agent-browser";
    runtimeInputs = [
      pkgs.agent-browser
      pkgs.docker
    ];

    text = ''
      set -euo pipefail

      CONTAINER_NAME="cloak"
      IMAGE="cloakhq/cloakbrowser"
      CDP_PORT="9222"

      if ! docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
        docker run -d \
          --name "$CONTAINER_NAME" \
          -p 127.0.0.1:''${CDP_PORT}:9222 \
          "$IMAGE" cloakserve >/dev/null
      elif [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME")" != "true" ]; then
        docker start "$CONTAINER_NAME" >/dev/null
      fi

      exec ${pkgs.agent-browser}/bin/agent-browser --cdp "$CDP_PORT" "$@"
    '';
  };

  # Only mac-pro gets the tailnet wrapper, only kk-spartans gets the cloak
  # wrapper; every other host gets stock upstream agent-browser, no wrapper.
  agent-browser =
    if isMacPro then
      agent-browser-tailnet
    else if isKkSpartans then
      agent-browser-cloak
    else
      pkgs.agent-browser;

  # Upstream ships its skills next to the CLI; pin the matching repo revision
  # so the skill text and the binary stay in sync.
  agent-browser-skill = pkgs.fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "82eadcee41240b1c8477870f846bc8528e77a8a6";
    hash = "sha256-NbIl24zbSqAbKbZcT5mGGgaUmT1FIwnUMMkMx+za0DU=";
  };
in
{
  options.programs.agent-browser = {
    enable = lib.mkEnableOption "the agent-browser CLI and its agent skills";

    skills = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the upstream agent-browser skill plus the local policy overlay.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ agent-browser ];

    home.file.".agent-browser/config.json".text = ''
      {
        "$schema": "https://agent-browser.dev/schema.json",
        "profile": "~/.agent-browser/browser-data",
        "headed": true
      }
    '';

    # The agent-skills module comes from the consumer's own flake input; only
    # wire the skills up when it is present.
    programs = lib.mkIf (options.programs ? agent-skills) {
      agent-skills = lib.mkIf cfg.skills {
        sources = {
          agent-browser = {
            path = agent-browser-skill;
            subdir = "skills";
          };

          # Local policy overlay: plain `agent-browser` usage, no named
          # sessions (see ./agent-browser-local/SKILL.md). This is what stops
          # every agent from wrapping commands in AGENT_BROWSER_SESSION.
          agent-browser-local = {
            path = ./agent-browser-local;
            subdir = ".";
          };
        };

        skills.enable = [
          "agent-browser"
          "agent-browser-local"
        ];
      };
    };
  };
}
