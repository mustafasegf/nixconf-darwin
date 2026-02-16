#!/usr/bin/env zsh
# yo.zsh - LLM-powered shell command assistant for Zsh
# Uses `opencode run` as the AI backend
#
# Usage:
#   yo <natural language query>
#   yo find all python files modified today
#   yo why did that command fail?
#
# Config: ~/.config/yo/config (key=value, sourced as zsh)
#   YO_MODEL   - model in provider/model format (default: anthropic/claude-sonnet-4-5-20250929)
#   YO_VARIANT - model variant/reasoning effort (default: unset)

# --- Fast config loading (source a simple key=value file) ---
_yo_config="${XDG_CONFIG_HOME:-$HOME/.config}/yo/config"

yo() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: yo <natural language query>" >&2
    echo "  yo find all python files modified today" >&2
    echo "  yo why did that command fail?" >&2
    echo "  yo-config            # edit config" >&2
    return 1
  fi

  if ! command -v opencode &>/dev/null; then
    echo "Error: opencode is required. Install it from https://opencode.ai" >&2
    return 1
  fi

  # Load config (fast: just source a small file)
  local YO_MODEL YO_VARIANT
  [[ -f "$_yo_config" ]] && source "$_yo_config"
  YO_MODEL="${YO_MODEL:-anthropic/claude-sonnet-4-5-20250929}"

  local query="$*"
  local shell_info="OS: $(uname -s), Shell: zsh ${ZSH_VERSION}, User: ${USER}, PWD: ${PWD}"

  local prompt="You are a shell command assistant in the user's zsh terminal.
Environment: ${shell_info}

Rules:
- If the user wants a COMMAND: respond with ONLY the command on a single line prefixed with CMD: (e.g. CMD:find . -name '*.py')
- If the user wants an ANSWER (explanation, question, help): respond with ONLY the answer text, no CMD: prefix
- For commands: give a single executable shell command (use && or ; for multi-step)
- For answers: be concise and terminal-friendly, no markdown
- If ambiguous, prefer generating a command
- NEVER wrap output in code blocks or add explanation around a CMD: line

Recent command history for context:
$(fc -l -n -20 2>/dev/null | tail -20)

User request: ${query}"

  # Build opencode args
  local -a oc_args=(run --model "$YO_MODEL")
  [[ -n "$YO_VARIANT" ]] && oc_args+=(--variant "$YO_VARIANT")
  oc_args+=("$prompt")

  echo -n "[$YO_MODEL] thinking..." >&2

  local response
  response=$(opencode "${oc_args[@]}" 2>/dev/null)
  local rc=$?

  # Clear spinner
  echo -ne "\r\033[K" >&2

  if [[ $rc -ne 0 ]] || [[ -z "$response" ]]; then
    echo "Error: opencode failed (exit $rc)" >&2
    [[ -n "$response" ]] && echo "$response" >&2
    return 1
  fi

  # Parse response: CMD: prefix means command, otherwise it's an answer
  # Handle potential multi-line where first line is CMD:
  local first_line="${response%%$'\n'*}"

  if [[ "$first_line" == CMD:* ]]; then
    local cmd="${first_line#CMD:}"
    # Trim leading whitespace
    cmd="${cmd#"${cmd%%[![:space:]]*}"}"
    if [[ -n "$cmd" ]]; then
      print -z "$cmd"
    else
      echo "Error: empty command from AI" >&2
      return 1
    fi
  else
    # It's an answer - print it
    echo "$response"
  fi
}

# Edit config
yo-config() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/yo"
  if [[ ! -f "$config_dir/config" ]]; then
    mkdir -p "$config_dir"
    cat > "$config_dir/config" <<'DEFAULTCONF'
# yo.zsh configuration
# Model to use (run `opencode models` to see available models)
YO_MODEL=anthropic/claude-sonnet-4-5-20250929

# Model variant / reasoning effort (optional, e.g. high, max, minimal)
# YO_VARIANT=
DEFAULTCONF
    echo "Created default config at $config_dir/config" >&2
  fi
  ${EDITOR:-vim} "$config_dir/config"
}
