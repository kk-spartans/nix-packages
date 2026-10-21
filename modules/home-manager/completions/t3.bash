###-begin-t3-completions-###
#
# Static completion script for Bash
#
# Installation:
#   t3 --completions bash >> ~/.bashrc
#

if ! type _init_completion &>/dev/null; then
  _init_completion()
  {
    COMPREPLY=()
    local _i _j=0 _piece _line="$COMP_LINE"
    words=("${COMP_WORDS[0]}")
    cword=0
    _line="${_line#*"${COMP_WORDS[0]}"}"
    for ((_i = 1; _i < ${#COMP_WORDS[@]}; _i++)); do
      _piece="${COMP_WORDS[_i]}"
      if [[ "$_line" == [[:blank:]]* ]]; then
        ((_j++))
        words[_j]="$_piece"
      else
        words[_j]="${words[_j]}$_piece"
      fi
      ((_i == COMP_CWORD)) && cword=$_j
      _line="${_line#*"$_piece"}"
    done
    cur="${words[cword]}"
    prev=""
    ((cword > 0)) && prev="${words[cword-1]}"
    return 0
  }
fi

_t3--choices()
{
  local _cur="$1" _word="$2"; shift 2

  local _head="${_cur%"$_word"}"
  local _open=""
  case "$_head" in
    *\') _open="'" ;;
    *\") _open='"' ;;
  esac

  local _prefix="$_cur" _committed="$_head"
  _prefix=${_prefix//\\/}; _prefix=${_prefix//\"/}; _prefix=${_prefix//\'/}
  _committed=${_committed//\\/}; _committed=${_committed//\"/}; _committed=${_committed//\'/}

  COMPREPLY=()
  local _choice _rest _match
  for _choice in "$@"; do
    [[ "$_choice" == "$_prefix"* ]] || continue
    _rest="${_choice#"$_committed"}"
    case "$_open" in
      "'")
        if [[ "$_head" == "'" ]]; then
          _match=${_rest//\'/\'\\\'\'}
        else
          [[ "$_rest" == *\'* ]] && continue
          _match="$_rest"
        fi
        ;;
      '"')
        _match="${_rest//\\/\\\\}"
        _match="${_match//\$/\\$}"
        _match="${_match//\`/\\\`}"
        _match="${_match//\"/\\\"}"
        ;;
      *)
        printf -v _match '%q' "$_rest"
        [[ -z "$_head" && "$_match" == '~'* ]] && _match="\\$_match"
        ;;
    esac
    [[ -n "$_open" && "$_match" == *"$_open" ]] && _match+="$_open"
    COMPREPLY+=("$_match")
  done
}

_t3()
{
  local cur prev words cword i
  local _command_index=0
  _init_completion -n "$COMP_WORDBREAKS" || return
  local _comp_word="$2"

  # Flag value completions
  case "$prev" in
    --mode)
      _t3--choices "$cur" "$_comp_word" 'web' 'desktop'
      return
      ;;
  esac

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      --mode) _skip_next=1 ;;
      --mode=*) ;;
      --port) _skip_next=1 ;;
      --port=*) ;;
      --host) _skip_next=1 ;;
      --host=*) ;;
      --base-dir) _skip_next=1 ;;
      --base-dir=*) ;;
      --dev-url) _skip_next=1 ;;
      --dev-url=*) ;;
      --bootstrap-fd) _skip_next=1 ;;
      --bootstrap-fd=*) ;;
      --tailscale-serve-port) _skip_next=1 ;;
      --tailscale-serve-port=*) ;;
      help)
        _t3_help "$i"
        return
        ;;
      start)
        _t3_start "$i"
        return
        ;;
      serve)
        _t3_serve "$i"
        return
        ;;
      app)
        _t3_app "$i"
        return
        ;;
      pair)
        _t3_pair "$i"
        return
        ;;
      auth)
        _t3_auth "$i"
        return
        ;;
      browser)
        _t3_browser "$i"
        return
        ;;
      project)
        _t3_project "$i"
        return
        ;;
      thread)
        _t3_thread "$i"
        return
        ;;
      service)
        _t3_service "$i"
        return
        ;;
      update)
        _t3_update "$i"
        return
        ;;
      uninstall)
        _t3_uninstall "$i"
        return
        ;;
      theme)
        _t3_theme "$i"
        return
        ;;
      trace)
        _t3_trace "$i"
        return
        ;;
      doctor)
        _t3_doctor "$i"
        return
        ;;
      triage)
        _t3_triage "$i"
        return
        ;;
      connect)
        _t3_connect "$i"
        return
        ;;
    esac
  done

  local _used_0="" _used_1="" _used_2="" _used_3="" _used_4="" _used_5="" _used_6="" _used_7="" _used_8="" _used_9="" _used_10=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --mode) _used_0=1 ;;
      --port) _used_1=1 ;;
      --host) _used_2=1 ;;
      --base-dir) _used_3=1 ;;
      --dev-url) _used_4=1 ;;
      --no-browser|--no-no-browser) _used_5=1 ;;
      --bootstrap-fd) _used_6=1 ;;
      --auto-bootstrap-project-from-cwd|--no-auto-bootstrap-project-from-cwd) _used_7=1 ;;
      --log-websocket-events|--log-ws-events|--no-log-websocket-events) _used_8=1 ;;
      --tailscale-serve|--no-tailscale-serve) _used_9=1 ;;
      --tailscale-serve-port) _used_10=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --mode"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --port"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --host"
  [[ -n "$_used_3" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_4" ]] || _filtered_flags+=" --dev-url"
  [[ -n "$_used_5" ]] || _filtered_flags+=" --no-browser --no-no-browser"
  [[ -n "$_used_6" ]] || _filtered_flags+=" --bootstrap-fd"
  [[ -n "$_used_7" ]] || _filtered_flags+=" --auto-bootstrap-project-from-cwd --no-auto-bootstrap-project-from-cwd"
  [[ -n "$_used_8" ]] || _filtered_flags+=" --log-websocket-events --log-ws-events --no-log-websocket-events"
  [[ -n "$_used_9" ]] || _filtered_flags+=" --tailscale-serve --no-tailscale-serve"
  [[ -n "$_used_10" ]] || _filtered_flags+=" --tailscale-serve-port"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

  COMPREPLY=( $(compgen -W 'help start serve app pair auth browser project thread service update uninstall theme trace doctor triage connect' -- "$cur") )
}

_t3_help()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

}

_t3_start()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
    --mode)
      _t3--choices "$cur" "$_comp_word" 'web' 'desktop'
      return
      ;;
  esac

  local _used_0="" _used_1="" _used_2="" _used_3="" _used_4="" _used_5="" _used_6="" _used_7="" _used_8="" _used_9="" _used_10=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --mode) _used_0=1 ;;
      --port) _used_1=1 ;;
      --host) _used_2=1 ;;
      --base-dir) _used_3=1 ;;
      --dev-url) _used_4=1 ;;
      --no-browser|--no-no-browser) _used_5=1 ;;
      --bootstrap-fd) _used_6=1 ;;
      --auto-bootstrap-project-from-cwd|--no-auto-bootstrap-project-from-cwd) _used_7=1 ;;
      --log-websocket-events|--log-ws-events|--no-log-websocket-events) _used_8=1 ;;
      --tailscale-serve|--no-tailscale-serve) _used_9=1 ;;
      --tailscale-serve-port) _used_10=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --mode"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --port"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --host"
  [[ -n "$_used_3" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_4" ]] || _filtered_flags+=" --dev-url"
  [[ -n "$_used_5" ]] || _filtered_flags+=" --no-browser --no-no-browser"
  [[ -n "$_used_6" ]] || _filtered_flags+=" --bootstrap-fd"
  [[ -n "$_used_7" ]] || _filtered_flags+=" --auto-bootstrap-project-from-cwd --no-auto-bootstrap-project-from-cwd"
  [[ -n "$_used_8" ]] || _filtered_flags+=" --log-websocket-events --log-ws-events --no-log-websocket-events"
  [[ -n "$_used_9" ]] || _filtered_flags+=" --tailscale-serve --no-tailscale-serve"
  [[ -n "$_used_10" ]] || _filtered_flags+=" --tailscale-serve-port"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_serve()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
    --mode)
      _t3--choices "$cur" "$_comp_word" 'web' 'desktop'
      return
      ;;
  esac

  local _used_0="" _used_1="" _used_2="" _used_3="" _used_4="" _used_5="" _used_6="" _used_7="" _used_8="" _used_9="" _used_10=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --mode) _used_0=1 ;;
      --port) _used_1=1 ;;
      --host) _used_2=1 ;;
      --base-dir) _used_3=1 ;;
      --dev-url) _used_4=1 ;;
      --no-browser|--no-no-browser) _used_5=1 ;;
      --bootstrap-fd) _used_6=1 ;;
      --auto-bootstrap-project-from-cwd|--no-auto-bootstrap-project-from-cwd) _used_7=1 ;;
      --log-websocket-events|--log-ws-events|--no-log-websocket-events) _used_8=1 ;;
      --tailscale-serve|--no-tailscale-serve) _used_9=1 ;;
      --tailscale-serve-port) _used_10=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --mode"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --port"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --host"
  [[ -n "$_used_3" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_4" ]] || _filtered_flags+=" --dev-url"
  [[ -n "$_used_5" ]] || _filtered_flags+=" --no-browser --no-no-browser"
  [[ -n "$_used_6" ]] || _filtered_flags+=" --bootstrap-fd"
  [[ -n "$_used_7" ]] || _filtered_flags+=" --auto-bootstrap-project-from-cwd --no-auto-bootstrap-project-from-cwd"
  [[ -n "$_used_8" ]] || _filtered_flags+=" --log-websocket-events --log-ws-events --no-log-websocket-events"
  [[ -n "$_used_9" ]] || _filtered_flags+=" --tailscale-serve --no-tailscale-serve"
  [[ -n "$_used_10" ]] || _filtered_flags+=" --tailscale-serve-port"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_app()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_pair()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
    --scope)
      _t3--choices "$cur" "$_comp_word" 'orchestration:read' 'orchestration:operate' 'settings:write' 'providers:manage' 'environment:maintain' 'preview:operate' 'diagnostics:read' 'terminal:read' 'terminal:operate' 'filesystem:read' 'filesystem:write' 'source-control:write' 'access:read' 'access:write' 'relay:read' 'relay:write'
      return
      ;;
  esac

  local _used_0="" _used_1="" _used_2="" _used_3="" _used_4="" _used_5=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --scope) _used_1=1 ;;
      --ttl) _used_2=1 ;;
      --label) _used_3=1 ;;
      --tailscale|--no-tailscale) _used_4=1 ;;
      --tailscale-serve-port) _used_5=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --scope"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --ttl"
  [[ -n "$_used_3" ]] || _filtered_flags+=" --label"
  [[ -n "$_used_4" ]] || _filtered_flags+=" --tailscale --no-tailscale"
  [[ -n "$_used_5" ]] || _filtered_flags+=" --tailscale-serve-port"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_auth()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      pairing)
        _t3_auth_pairing "$i"
        return
        ;;
      session)
        _t3_auth_session "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'pairing session' -- "$cur") )
}

_t3_auth_pairing()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      create)
        _t3_auth_pairing_create "$i"
        return
        ;;
      list)
        _t3_auth_pairing_list "$i"
        return
        ;;
      revoke)
        _t3_auth_pairing_revoke "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'create list revoke' -- "$cur") )
}

_t3_auth_pairing_create()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
    --scope)
      _t3--choices "$cur" "$_comp_word" 'orchestration:read' 'orchestration:operate' 'settings:write' 'providers:manage' 'environment:maintain' 'preview:operate' 'diagnostics:read' 'terminal:read' 'terminal:operate' 'filesystem:read' 'filesystem:write' 'source-control:write' 'access:read' 'access:write' 'relay:read' 'relay:write'
      return
      ;;
  esac

  local _used_0="" _used_1="" _used_2="" _used_3="" _used_4="" _used_5="" _used_6=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --dev-url) _used_1=1 ;;
      --scope) _used_2=1 ;;
      --ttl) _used_3=1 ;;
      --label) _used_4=1 ;;
      --base-url) _used_5=1 ;;
      --json|--no-json) _used_6=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --dev-url"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --scope"
  [[ -n "$_used_3" ]] || _filtered_flags+=" --ttl"
  [[ -n "$_used_4" ]] || _filtered_flags+=" --label"
  [[ -n "$_used_5" ]] || _filtered_flags+=" --base-url"
  [[ -n "$_used_6" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_auth_pairing_list()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --dev-url) _used_1=1 ;;
      --json|--no-json) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --dev-url"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_auth_pairing_revoke()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --dev-url) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --dev-url"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_auth_session()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      issue)
        _t3_auth_session_issue "$i"
        return
        ;;
      list)
        _t3_auth_session_list "$i"
        return
        ;;
      revoke)
        _t3_auth_session_revoke "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'issue list revoke' -- "$cur") )
}

_t3_auth_session_issue()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
    --scope)
      _t3--choices "$cur" "$_comp_word" 'orchestration:read' 'orchestration:operate' 'settings:write' 'providers:manage' 'environment:maintain' 'preview:operate' 'diagnostics:read' 'terminal:read' 'terminal:operate' 'filesystem:read' 'filesystem:write' 'source-control:write' 'access:read' 'access:write' 'relay:read' 'relay:write'
      return
      ;;
  esac

  local _used_0="" _used_1="" _used_2="" _used_3="" _used_4="" _used_5="" _used_6="" _used_7=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --dev-url) _used_1=1 ;;
      --scope) _used_2=1 ;;
      --ttl) _used_3=1 ;;
      --label) _used_4=1 ;;
      --subject) _used_5=1 ;;
      --token-only|--no-token-only) _used_6=1 ;;
      --json|--no-json) _used_7=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --dev-url"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --scope"
  [[ -n "$_used_3" ]] || _filtered_flags+=" --ttl"
  [[ -n "$_used_4" ]] || _filtered_flags+=" --label"
  [[ -n "$_used_5" ]] || _filtered_flags+=" --subject"
  [[ -n "$_used_6" ]] || _filtered_flags+=" --token-only --no-token-only"
  [[ -n "$_used_7" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_auth_session_list()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --dev-url) _used_1=1 ;;
      --json|--no-json) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --dev-url"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_auth_session_revoke()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --dev-url) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --dev-url"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_browser()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      setup)
        _t3_browser_setup "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'setup' -- "$cur") )
}

_t3_browser_setup()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_project()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      add)
        _t3_project_add "$i"
        return
        ;;
      remove)
        _t3_project_remove "$i"
        return
        ;;
      rename)
        _t3_project_rename "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'add remove rename' -- "$cur") )
}

_t3_project_add()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --title) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --title"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_project_remove()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --force|--no-force) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --force --no-force"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_project_rename()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_thread()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      list)
        _t3_thread_list "$i"
        return
        ;;
      start)
        _t3_thread_start "$i"
        return
        ;;
      send)
        _t3_thread_send "$i"
        return
        ;;
      show)
        _t3_thread_show "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'list start send show' -- "$cur") )
}

_t3_thread_list()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --project) _used_1=1 ;;
      --json|--no-json) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --project"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_thread_start()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2="" _used_3="" _used_4="" _used_5="" _used_6="" _used_7=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --title) _used_1=1 ;;
      --provider) _used_2=1 ;;
      --model) _used_3=1 ;;
      --worktree) _used_4=1 ;;
      --branch) _used_5=1 ;;
      --wait|--no-wait) _used_6=1 ;;
      --json|--no-json) _used_7=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --title"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --provider"
  [[ -n "$_used_3" ]] || _filtered_flags+=" --model"
  [[ -n "$_used_4" ]] || _filtered_flags+=" --worktree"
  [[ -n "$_used_5" ]] || _filtered_flags+=" --branch"
  [[ -n "$_used_6" ]] || _filtered_flags+=" --wait --no-wait"
  [[ -n "$_used_7" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_thread_send()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --wait|--no-wait) _used_1=1 ;;
      --json|--no-json) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --wait --no-wait"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_thread_show()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --messages) _used_1=1 ;;
      --json|--no-json) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --messages"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_service()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      install)
        _t3_service_install "$i"
        return
        ;;
      restart)
        _t3_service_restart "$i"
        return
        ;;
      uninstall)
        _t3_service_uninstall "$i"
        return
        ;;
      status)
        _t3_service_status "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'install restart uninstall status' -- "$cur") )
}

_t3_service_install()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --allow-downgrade|--no-allow-downgrade) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --allow-downgrade --no-allow-downgrade"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_service_restart()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_service_uninstall()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_service_status()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_update()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
    --channel)
      _t3--choices "$cur" "$_comp_word" 'stable' 'nightly' 'preview'
      return
      ;;
  esac

  local _used_0="" _used_1="" _used_2="" _used_3=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --channel) _used_1=1 ;;
      --allow-downgrade|--no-allow-downgrade) _used_2=1 ;;
      --yes|-y|--no-yes) _used_3=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --channel"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --allow-downgrade --no-allow-downgrade"
  [[ -n "$_used_3" ]] || _filtered_flags+=" --yes -y --no-yes"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_uninstall()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --yes|-y|--no-yes) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --yes -y --no-yes"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_theme()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      set)
        _t3_theme_set "$i"
        return
        ;;
      clear)
        _t3_theme_clear "$i"
        return
        ;;
      show)
        _t3_theme_show "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'set clear show' -- "$cur") )
}

_t3_theme_set()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --id) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --id"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_theme_clear()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_theme_show()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_trace()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      summary)
        _t3_trace_summary "$i"
        return
        ;;
    esac
  done

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    return
  fi

  COMPREPLY=( $(compgen -W 'summary' -- "$cur") )
}

_t3_trace_summary()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --since) _used_1=1 ;;
      --limit) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --since"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --limit"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_doctor()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --fix|--no-fix) _used_1=1 ;;
      --dry-run|--no-dry-run) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --fix --no-fix"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --dry-run --no-dry-run"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_triage()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
    --agent)
      _t3--choices "$cur" "$_comp_word" 'claude' 'codex'
      return
      ;;
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --agent) _used_1=1 ;;
      --model) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --agent"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --model"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_connect()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  # Subcommand dispatch
  local cmd _skip_next=0
  for ((i = _command_index + 1; i < cword; i++)); do
    if (( _skip_next )); then
      _skip_next=0
      continue
    fi
    case "${words[i]}" in
      --base-dir) _skip_next=1 ;;
      --base-dir=*) ;;
      login)
        _t3_connect_login "$i"
        return
        ;;
      link)
        _t3_connect_link "$i"
        return
        ;;
      publish)
        _t3_connect_publish "$i"
        return
        ;;
      status)
        _t3_connect_status "$i"
        return
        ;;
      unlink)
        _t3_connect_unlink "$i"
        return
        ;;
      logout)
        _t3_connect_logout "$i"
        return
        ;;
    esac
  done

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --headless|--no-headless) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --headless --no-headless"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

  COMPREPLY=( $(compgen -W 'login link publish status unlink logout' -- "$cur") )
}

_t3_connect_login()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --headless|--no-headless) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --headless --no-headless"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_connect_link()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1="" _used_2=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --headless|--no-headless) _used_1=1 ;;
      --publish-only|--no-publish-only) _used_2=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --headless --no-headless"
  [[ -n "$_used_2" ]] || _filtered_flags+=" --publish-only --no-publish-only"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_connect_publish()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --disable|--no-disable) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --disable --no-disable"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_connect_status()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0="" _used_1=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
      --json|--no-json) _used_1=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"
  [[ -n "$_used_1" ]] || _filtered_flags+=" --json --no-json"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_connect_unlink()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

_t3_connect_logout()
{
  local cur prev words cword i
  local _command_index="$1"
  _init_completion -n "$COMP_WORDBREAKS" || return

  # Flag value completions
  case "$prev" in
  esac

  local _used_0=""
  for ((i = 1; i < cword; i++)); do
    case "${words[i]%%=*}" in
      --base-dir) _used_0=1 ;;
    esac
  done
  local _filtered_flags=""
  [[ -n "$_used_0" ]] || _filtered_flags+=" --base-dir"

  # Complete flags (filtered) and subcommands
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$_filtered_flags" -- "$cur") )
    return
  fi

}

complete -F _t3 t3
###-end-t3-completions-###
