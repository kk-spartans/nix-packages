{ pkgs }:
pkgs.writeShellApplication {
  name = "terminal-agent-browser";

  runtimeInputs = with pkgs; [
    agent-browser-bin
    coreutils
    jq
    terminal-browser
  ];

  text = ''
    set -euo pipefail

    sanitize() {
      printf '%s' "$1" | tr ':' '-' | tr -c 'a-zA-Z0-9_-' '-'
    }

    # Escape hatch: the caller already pins the connection/session, so skip
    # discovery and run the declarative agent-browser directly.
    for arg in "$@"; do
      case "$arg" in
        --cdp*|--session|--namespace|--auto-connect|--executable-path|--provider)
          exec ${pkgs.agent-browser-bin}/bin/agent-browser "$@"
          ;;
      esac
    done

    # Per-herdr-tab session: agents and terminal-browser panes in the same
    # herdr tab share it, different tabs are isolated. Derived from HERDR_TAB_ID
    # at invocation time, so no shell integration is needed; explicit env wins
    # as an override.
    if [ -n "''${TERMINAL_AGENT_BROWSER_SESSION:-}" ]; then
      SESSION="''${TERMINAL_AGENT_BROWSER_SESSION}"
    elif [ -n "''${HERDR_TAB_ID:-}" ]; then
      SESSION="terminal-tab-$(sanitize "''${HERDR_TAB_ID}")"
    else
      SESSION="terminal-agent-nontab"
    fi

    # Explicit CDP port wins (useful outside herdr or in scripts).
    if [ -n "''${TERMINAL_BROWSER_CDP_PORT:-}" ]; then
      exec ${pkgs.agent-browser-bin}/bin/agent-browser --session "$SESSION" --cdp "''${TERMINAL_BROWSER_CDP_PORT}" "$@"
    fi

    if ! LS_JSON="$(${pkgs.terminal-browser}/bin/terminal-browser ls --json 2>/dev/null)"; then
      echo "terminal-agent-browser: terminal-browser daemon not reachable (is a browser open?)" >&2
      exit 1
    fi

    COUNT="$(printf '%s' "$LS_JSON" | jq '[.browsers // [] | .[] | select(.inCurrentTab == true)] | length')"

    if [ "$COUNT" -eq 0 ]; then
      echo "terminal-agent-browser: no terminal browser in this terminal tab -- start one with: terminal-browser open <url>" >&2
      exit 1
    fi

    if [ "$COUNT" -gt 1 ]; then
      echo "terminal-agent-browser: several browsers match this terminal tab -- set TERMINAL_BROWSER_KEY to one of:" >&2
      printf '%s' "$LS_JSON" | jq -r '.browsers[] | select(.inCurrentTab == true) | "  \(.key)"' >&2
      exit 1
    fi

    if [ -n "''${TERMINAL_BROWSER_KEY:-}" ]; then
      CDP_PORT="$(printf '%s' "$LS_JSON" | jq -r --arg k "''${TERMINAL_BROWSER_KEY}" '.browsers[] | select(.inCurrentTab == true and .key == $k) | .cdpPort // empty')"
      if [ -z "$CDP_PORT" ]; then
        echo "terminal-agent-browser: no browser with key ''${TERMINAL_BROWSER_KEY} in this terminal tab" >&2
        exit 1
      fi
    else
      CDP_PORT="$(printf '%s' "$LS_JSON" | jq -r '[.browsers[] | select(.inCurrentTab == true)][0].cdpPort // empty')"
    fi

    if [ -z "$CDP_PORT" ]; then
      echo "terminal-agent-browser: browser has no debugging port yet" >&2
      exit 1
    fi

    # Always pin --cdp: agent-browser then drives terminal-browser's existing
    # Chromium over CDP and never needs `agent-browser install` downloads.
    exec ${pkgs.agent-browser-bin}/bin/agent-browser --session "$SESSION" --cdp "$CDP_PORT" "$@"
  '';

  meta = with pkgs.lib; {
    description = "Per-herdr-tab agent-browser wrapper that drives the terminal-browser instance in the current tab over CDP";
    license = licenses.mit;
    mainProgram = "terminal-agent-browser";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
