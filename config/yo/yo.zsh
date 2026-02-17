#!/usr/bin/env zsh
# yo.zsh - LLM-powered shell command assistant for Zsh
# Supports opencode (default), or direct curl to OpenAI/Anthropic-compatible APIs
# Includes Anthropic OAuth for Claude Pro/Max subscriptions
#
# Usage:
#   yo <natural language query>
#   yo find all python files modified today
#   yo why did that command fail?
#   yo login                 # OAuth login for Claude Pro/Max
#   yo logout                # clear OAuth tokens
#   yo status                # show auth status
#
# Config: ~/.config/yo/config (key=value, sourced as zsh)
#   YO_PROVIDER  - opencode (default), anthropic, openai, groq, ollama, custom
#   YO_MODEL     - model name (each provider has a sensible default)
#   YO_API_KEY   - API key (falls back to ~/.local/share/opencode/auth.json)
#   YO_API_URL   - custom API endpoint (only needed for "custom" provider)
#   YO_API_TYPE  - openai or anthropic (only needed for "custom" provider)
#   YO_VARIANT   - model variant/reasoning effort (opencode backend only)

# --- Load zsh/datetime for EPOCHREALTIME ---
zmodload zsh/datetime 2>/dev/null

# --- Config & paths ---
_yo_config="${XDG_CONFIG_HOME:-$HOME/.config}/yo/config"
_yo_auth_json="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/auth.json"
_yo_log="${XDG_DATA_HOME:-$HOME/.local/share}/yo/debug.log"

# --- OAuth constants (same as Claude Code) ---
_YO_OAUTH_CLIENT_ID="9d1c250a-e61b-44d9-88ed-5944d1962f5e"
_YO_OAUTH_TOKEN_URL="https://console.anthropic.com/v1/oauth/token"
_YO_OAUTH_REDIRECT_URI="https://console.anthropic.com/oauth/code/callback"
_YO_OAUTH_SCOPES="org:create_api_key user:profile user:inference"

# --- Logging (auto-rotates at ~100KB, keeps 1 backup) ---
_yo_log() {
  local log_dir="${_yo_log%/*}"
  [[ -d "$log_dir" ]] || mkdir -p "$log_dir"
  # Rotate if over 100KB
  if [[ -f "$_yo_log" ]] && (( $(command stat -f%z "$_yo_log" 2>/dev/null || command stat -c%s "$_yo_log" 2>/dev/null || echo 0) > 102400 )); then
    mv -f "$_yo_log" "${_yo_log}.old"
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$_yo_log"
}

# --- URL encode via jq ---
_yo_urlencode() {
  jq -rn --arg s "$1" '$s | @uri'
}

# --- PKCE generation (S256) using openssl ---
_yo_generate_pkce() {
  local verifier challenge
  verifier=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
  challenge=$(printf '%s' "$verifier" | openssl dgst -sha256 -binary | openssl base64 | tr '+/' '-_' | tr -d '=')
  # Return as "verifier challenge"
  echo "$verifier $challenge"
}

# --- Refresh Anthropic OAuth token ---
_yo_refresh_oauth() {
  local refresh_token="$1"

  local payload
  payload=$(jq -n \
    --arg rt "$refresh_token" \
    --arg cid "$_YO_OAUTH_CLIENT_ID" \
    '{grant_type: "refresh_token", refresh_token: $rt, client_id: $cid}')

  local raw
  raw=$(curl -s --max-time 15 \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$_YO_OAUTH_TOKEN_URL" 2>/dev/null)
  [[ $? -ne 0 ]] && return 1

  local access refresh expires_in
  access=$(echo "$raw" | jq -r '.access_token // empty')
  refresh=$(echo "$raw" | jq -r '.refresh_token // empty')
  expires_in=$(echo "$raw" | jq -r '.expires_in // empty')

  [[ -z "$access" ]] && return 1

  # Update opencode auth.json with new tokens
  local expires_ms=$(( $(date +%s) * 1000 + ${expires_in:-3600} * 1000 ))
  local tmp
  tmp=$(jq --arg a "$access" --arg r "$refresh" --argjson e "$expires_ms" \
    '.anthropic.access = $a | .anthropic.refresh = $r | .anthropic.expires = $e' \
    "$_yo_auth_json")
  echo "$tmp" > "$_yo_auth_json"

  echo "$access"
}

# --- Provider presets ---
# Each sets: _url, _api_type, _default_model, _auth_name
_yo_preset_anthropic() {
  _url="https://api.anthropic.com/v1/messages"
  _api_type="anthropic"
  _default_model="claude-sonnet-4-5-20250929"
  _auth_name="anthropic"
}
_yo_preset_openai() {
  _url="https://api.openai.com/v1/chat/completions"
  _api_type="openai"
  _default_model="gpt-4o"
  _auth_name="openai"
}
_yo_preset_groq() {
  _url="https://api.groq.com/openai/v1/chat/completions"
  _api_type="openai"
  _default_model="llama-3.3-70b-versatile"
  _auth_name="groq"
}
_yo_preset_ollama() {
  _url="http://localhost:11434/v1/chat/completions"
  _api_type="openai"
  _default_model="llama3.2"
  _auth_name=""
}
_yo_preset_xai() {
  _url="https://api.x.ai/v1/chat/completions"
  _api_type="openai"
  _default_model="grok-3-mini-fast-latest"
  _auth_name="xai"
}
_yo_preset_deepseek() {
  _url="https://api.deepseek.com/v1/chat/completions"
  _api_type="openai"
  _default_model="deepseek-chat"
  _auth_name="deepseek"
}
_yo_preset_gemini() {
  _url="https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
  _api_type="openai"
  _default_model="gemini-2.5-flash"
  _auth_name="google"
}

# --- Resolve API key from opencode auth.json (with OAuth refresh) ---
_yo_resolve_key() {
  local provider_name="$1"
  [[ -z "$provider_name" || ! -f "$_yo_auth_json" ]] && return 1

  local auth_type
  auth_type=$(jq -r --arg p "$provider_name" '.[$p].type // empty' "$_yo_auth_json" 2>/dev/null)

  case "$auth_type" in
    api)
      local key
      key=$(jq -r --arg p "$provider_name" '.[$p].key // empty' "$_yo_auth_json" 2>/dev/null)
      [[ -n "$key" ]] && echo "$key" && return 0
      ;;
    oauth)
      local access expires refresh now_ms
      access=$(jq -r --arg p "$provider_name" '.[$p].access // empty' "$_yo_auth_json" 2>/dev/null)
      expires=$(jq -r --arg p "$provider_name" '.[$p].expires // 0' "$_yo_auth_json" 2>/dev/null)
      now_ms=$(( $(date +%s) * 1000 ))

      # Valid for at least 5 more minutes? Use it
      if [[ -n "$access" ]] && (( expires > now_ms + 300000 )); then
        echo "$access"
        return 0
      fi

      # Expired or close to expiry - refresh
      _yo_log "refreshing OAuth token for $provider_name"
      refresh=$(jq -r --arg p "$provider_name" '.[$p].refresh // empty' "$_yo_auth_json" 2>/dev/null)
      if [[ -n "$refresh" ]]; then
        local new_access
        new_access=$(_yo_refresh_oauth "$refresh")
        if [[ $? -eq 0 && -n "$new_access" ]]; then
          _yo_log "OAuth token refreshed for $provider_name"
          echo "$new_access"
          return 0
        fi
      fi

      _yo_log "ERROR: OAuth token refresh failed for $provider_name"
      ;;
  esac
  return 1
}

# --- curl: OpenAI-compatible API ---
_yo_curl_openai() {
  local url="$1" model="$2" key="$3" prompt="$4"
  local -a headers=(-H "Content-Type: application/json")
  [[ -n "$key" ]] && headers+=(-H "Authorization: Bearer $key")

  local payload
  payload=$(jq -n --arg model "$model" --arg content "$prompt" \
    '{model: $model, messages: [{role: "user", content: $content}], temperature: 0.2}')

  local raw
  raw=$(curl -s --max-time 60 "${headers[@]}" -d "$payload" "$url" 2>/dev/null)
  local rc=$?
  [[ $rc -ne 0 ]] && return 1

  local err
  err=$(echo "$raw" | jq -r '.error.message // empty' 2>/dev/null)
  if [[ -n "$err" ]]; then
    echo "API error: $err" >&2
    return 1
  fi

  echo "$raw" | jq -r '.choices[0].message.content // empty' 2>/dev/null
}

# --- curl: Anthropic API (handles both API key and OAuth) ---
_yo_curl_anthropic() {
  local url="$1" model="$2" key="$3" prompt="$4"
  local -a headers=(-H "Content-Type: application/json" -H "anthropic-version: 2023-06-01")
  local is_oauth=false

  # OAuth token (sk-ant-oat*) vs regular API key
  if [[ "$key" == sk-ant-oat* ]]; then
    is_oauth=true
    headers+=(-H "Authorization: Bearer $key")
    headers+=(-H "anthropic-beta: oauth-2025-04-20")
  else
    headers+=(-H "x-api-key: $key")
  fi

  local payload
  payload=$(jq -n --arg model "$model" --arg content "$prompt" \
    '{model: $model, max_tokens: 1024, messages: [{role: "user", content: $content}]}')

  # Append ?beta=true for OAuth requests
  local req_url="$url"
  [[ "$is_oauth" == true ]] && req_url="${url}?beta=true"

  local raw
  raw=$(curl -s --max-time 60 "${headers[@]}" -d "$payload" "$req_url" 2>/dev/null)
  local rc=$?
  [[ $rc -ne 0 ]] && return 1

  local err
  err=$(echo "$raw" | jq -r '.error.message // empty' 2>/dev/null)
  if [[ -n "$err" ]]; then
    echo "API error: $err" >&2
    _yo_log "Anthropic API error: $err"
    return 1
  fi

  # Handle potential thinking blocks in response - extract only text
  echo "$raw" | jq -r '[.content[] | select(.type == "text") | .text] | join("\n") // empty' 2>/dev/null
}

# =====================================================================
# OAuth login / logout / status
# =====================================================================
_yo_login() {
  local pkce_out verifier challenge
  pkce_out=$(_yo_generate_pkce)
  verifier="${pkce_out%% *}"
  challenge="${pkce_out#* }"

  local auth_url="https://claude.ai/oauth/authorize"
  auth_url+="?code=true"
  auth_url+="&client_id=${_YO_OAUTH_CLIENT_ID}"
  auth_url+="&response_type=code"
  auth_url+="&redirect_uri=$(_yo_urlencode "$_YO_OAUTH_REDIRECT_URI")"
  auth_url+="&scope=$(_yo_urlencode "$_YO_OAUTH_SCOPES")"
  auth_url+="&code_challenge=${challenge}"
  auth_url+="&code_challenge_method=S256"
  auth_url+="&state=${verifier}"

  echo "Logging in with Claude Pro/Max..."
  echo ""

  # Open browser
  if command -v open &>/dev/null; then
    open "$auth_url"
    echo "Browser opened. Authorize and copy the code."
  elif command -v xdg-open &>/dev/null; then
    xdg-open "$auth_url"
    echo "Browser opened. Authorize and copy the code."
  else
    echo "Open this URL in your browser:"
    echo "$auth_url"
  fi

  echo ""
  echo -n "Paste the authorization code: "
  read -r code
  [[ -z "$code" ]] && echo "No code provided" >&2 && return 1

  # code may be "authcode#state"
  local auth_code="${code%%#*}"
  local state=""
  [[ "$code" == *"#"* ]] && state="${code#*#}"

  local payload
  payload=$(jq -n \
    --arg code "$auth_code" \
    --arg state "$state" \
    --arg cid "$_YO_OAUTH_CLIENT_ID" \
    --arg uri "$_YO_OAUTH_REDIRECT_URI" \
    --arg cv "$verifier" \
    '{code: $code, state: $state, grant_type: "authorization_code", client_id: $cid, redirect_uri: $uri, code_verifier: $cv}')

  echo "Exchanging code for tokens..."

  local raw
  raw=$(curl -s --max-time 30 \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$_YO_OAUTH_TOKEN_URL" 2>/dev/null)

  local access refresh expires_in
  access=$(echo "$raw" | jq -r '.access_token // empty')
  refresh=$(echo "$raw" | jq -r '.refresh_token // empty')
  expires_in=$(echo "$raw" | jq -r '.expires_in // empty')

  if [[ -z "$access" ]]; then
    local err
    err=$(echo "$raw" | jq -r '.error_description // .error // empty')
    echo "Login failed${err:+: $err}" >&2
    _yo_log "ERROR: OAuth login failed: $err"
    return 1
  fi

  local expires_ms=$(( $(date +%s) * 1000 + ${expires_in:-3600} * 1000 ))

  # Save to opencode auth.json (shared with opencode)
  local auth_dir="${_yo_auth_json%/*}"
  [[ -d "$auth_dir" ]] || mkdir -p "$auth_dir"

  if [[ -f "$_yo_auth_json" ]]; then
    local tmp
    tmp=$(jq --arg a "$access" --arg r "$refresh" --argjson e "$expires_ms" \
      '.anthropic = {type: "oauth", refresh: $r, access: $a, expires: $e}' \
      "$_yo_auth_json")
    echo "$tmp" > "$_yo_auth_json"
  else
    jq -n --arg a "$access" --arg r "$refresh" --argjson e "$expires_ms" \
      '{anthropic: {type: "oauth", refresh: $r, access: $a, expires: $e}}' > "$_yo_auth_json"
  fi

  chmod 600 "$_yo_auth_json" 2>/dev/null

  _yo_log "OAuth login successful"
  echo "Login successful! Tokens saved."
  echo "Use YO_PROVIDER=anthropic to query Claude directly."
}

_yo_logout() {
  if [[ ! -f "$_yo_auth_json" ]]; then
    echo "No auth file found" >&2
    return 1
  fi

  # Remove only the anthropic entry
  local tmp
  tmp=$(jq 'del(.anthropic)' "$_yo_auth_json" 2>/dev/null)
  echo "$tmp" > "$_yo_auth_json"

  _yo_log "OAuth logout"
  echo "Anthropic OAuth tokens cleared."
}

_yo_status() {
  echo "Config: $_yo_config"
  if [[ -f "$_yo_config" ]]; then
    local YO_PROVIDER YO_MODEL YO_API_KEY
    source "$_yo_config"
    echo "  provider: ${YO_PROVIDER:-opencode}"
    echo "  model:    ${YO_MODEL:-<default>}"
    echo "  api_key:  ${YO_API_KEY:+set (explicit)}${YO_API_KEY:-<from auth.json>}"
  else
    echo "  (no config file)"
  fi

  echo ""
  echo "Auth: $_yo_auth_json"
  if [[ -f "$_yo_auth_json" ]]; then
    local providers ptype expires expires_sec now remaining
    providers=$(jq -r 'keys[]' "$_yo_auth_json" 2>/dev/null)
    for p in ${(f)providers}; do
      ptype=$(jq -r --arg p "$p" '.[$p].type // "?"' "$_yo_auth_json")
      if [[ "$ptype" == "oauth" ]]; then
        expires=$(jq -r --arg p "$p" '.[$p].expires // 0' "$_yo_auth_json")
        expires_sec=$(( expires / 1000 ))
        now=$(date +%s)
        if (( expires_sec > now )); then
          remaining=$(( (expires_sec - now) / 60 ))
          echo "  $p: oauth (valid, ${remaining}m remaining)"
        else
          echo "  $p: oauth (EXPIRED - run 'yo login' to refresh)"
        fi
      elif [[ "$ptype" == "api" ]]; then
        echo "  $p: api key"
      fi
    done
  else
    echo "  (no auth file)"
  fi
}

# =====================================================================
# Main function
# =====================================================================
yo() {
  # Subcommands
  case "$1" in
    login)  _yo_login;  return $? ;;
    logout) _yo_logout; return $? ;;
    status) _yo_status; return $? ;;
  esac

  if [[ $# -eq 0 ]]; then
    echo "Usage: yo <natural language query>" >&2
    echo "  yo find all python files modified today" >&2
    echo "  yo why did that command fail?" >&2
    echo "" >&2
    echo "Commands: yo login | yo logout | yo status | yo-config" >&2
    echo "Providers: opencode (default), anthropic, openai, groq, ollama, xai, deepseek, gemini, custom" >&2
    return 1
  fi

  # Load config
  local YO_PROVIDER YO_MODEL YO_API_KEY YO_API_URL YO_API_TYPE YO_VARIANT
  [[ -f "$_yo_config" ]] && source "$_yo_config"
  YO_PROVIDER="${YO_PROVIDER:-opencode}"

  local query="$*"
  local shell_info="OS: $(uname -s), Shell: zsh ${ZSH_VERSION}, User: ${USER}, PWD: ${PWD}"

  _yo_log "--- query: $query"
  _yo_log "provider=$YO_PROVIDER model=${YO_MODEL:-<default>}"

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

  local response

  if [[ "$YO_PROVIDER" == "opencode" ]]; then
    # --- opencode backend (original) ---
    if ! command -v opencode &>/dev/null; then
      echo "Error: opencode is required. Install from https://opencode.ai" >&2
      echo "  Or set YO_PROVIDER to use a direct API (anthropic, openai, groq, etc.)" >&2
      return 1
    fi

    YO_MODEL="${YO_MODEL:-anthropic/claude-sonnet-4-5-20250929}"
    local -a oc_args=(run --model "$YO_MODEL")
    [[ -n "$YO_VARIANT" ]] && oc_args+=(--variant "$YO_VARIANT")
    oc_args+=("$prompt")

    echo -n "[$YO_MODEL] thinking..." >&2
    local t_start=$EPOCHREALTIME
    response=$(opencode "${oc_args[@]}" 2>/dev/null)
    local rc=$?
    local t_end=$EPOCHREALTIME
    echo -ne "\r\033[K" >&2

    _yo_log "opencode exit=$rc time=$(printf '%.2f' $(( t_end - t_start )))s response_len=${#response}"

    if [[ $rc -ne 0 ]] || [[ -z "$response" ]]; then
      _yo_log "ERROR: opencode failed (exit $rc)"
      echo "Error: opencode failed (exit $rc)" >&2
      [[ -n "$response" ]] && echo "$response" >&2
      return 1
    fi
  else
    # --- Direct curl backend ---
    local _url _api_type _default_model _auth_name

    # Load preset or custom
    if typeset -f "_yo_preset_${YO_PROVIDER}" &>/dev/null; then
      "_yo_preset_${YO_PROVIDER}"
    elif [[ "$YO_PROVIDER" == "custom" ]]; then
      _url="${YO_API_URL}"
      _api_type="${YO_API_TYPE:-openai}"
      _default_model=""
      _auth_name=""
      if [[ -z "$_url" ]]; then
        echo "Error: YO_API_URL is required for custom provider" >&2
        return 1
      fi
    else
      echo "Error: unknown provider '$YO_PROVIDER'" >&2
      echo "Available: opencode, anthropic, openai, groq, ollama, xai, deepseek, gemini, custom" >&2
      return 1
    fi

    local model="${YO_MODEL:-$_default_model}"
    if [[ -z "$model" ]]; then
      echo "Error: YO_MODEL is required" >&2
      return 1
    fi

    # Resolve API key: explicit > auth.json (with auto-refresh for OAuth)
    local api_key="${YO_API_KEY}"
    if [[ -z "$api_key" && -n "$_auth_name" ]]; then
      api_key=$(_yo_resolve_key "$_auth_name")
      if [[ $? -ne 0 ]]; then
        echo "Error: no API key for '$YO_PROVIDER'" >&2
        echo "  Set YO_API_KEY in config, or run 'yo login' for Anthropic OAuth" >&2
        return 1
      fi
    fi

    _yo_log "url=$_url api_type=$_api_type model=$model key_source=${YO_API_KEY:+config}${YO_API_KEY:-auth.json}"

    echo -n "[$YO_PROVIDER/$model] thinking..." >&2

    local t_start=$EPOCHREALTIME
    case "$_api_type" in
      openai)
        response=$(_yo_curl_openai "$_url" "$model" "$api_key" "$prompt")
        ;;
      anthropic)
        response=$(_yo_curl_anthropic "$_url" "$model" "$api_key" "$prompt")
        ;;
      *)
        echo -ne "\r\033[K" >&2
        _yo_log "ERROR: unknown api_type=$_api_type"
        echo "Error: unknown API type '$_api_type' (use 'openai' or 'anthropic')" >&2
        return 1
        ;;
    esac

    local rc=$?
    local t_end=$EPOCHREALTIME
    echo -ne "\r\033[K" >&2

    _yo_log "curl exit=$rc time=$(printf '%.2f' $(( t_end - t_start )))s response_len=${#response}"

    if [[ $rc -ne 0 ]] || [[ -z "$response" ]]; then
      _yo_log "ERROR: API request failed (exit $rc)"
      echo "Error: API request failed" >&2
      return 1
    fi
  fi

  # Parse response: CMD: prefix means command, otherwise it's an answer
  local first_line="${response%%$'\n'*}"

  if [[ "$first_line" == CMD:* ]]; then
    local cmd="${first_line#CMD:}"
    cmd="${cmd#"${cmd%%[![:space:]]*}"}"
    if [[ -n "$cmd" ]]; then
      _yo_log "result=CMD cmd=$cmd"
      print -z "$cmd"
    else
      _yo_log "ERROR: empty command from AI"
      echo "Error: empty command from AI" >&2
      return 1
    fi
  else
    _yo_log "result=ANSWER len=${#response}"
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
#
# Provider: opencode (default), anthropic, openai, groq, ollama, xai, deepseek, gemini, custom
YO_PROVIDER=opencode

# Model name (each provider has a sensible default if unset)
#   opencode:  anthropic/claude-sonnet-4-5-20250929
#   anthropic: claude-sonnet-4-5-20250929
#   openai:    gpt-4o
#   groq:      llama-3.3-70b-versatile
#   ollama:    llama3.2
#   xai:       grok-3-mini-fast-latest
#   deepseek:  deepseek-chat
#   gemini:    gemini-2.5-flash
# YO_MODEL=

# API key (optional - falls back to ~/.local/share/opencode/auth.json)
# For Anthropic OAuth (Claude Pro/Max), run: yo login
# YO_API_KEY=

# For "custom" provider only:
# YO_API_URL=https://your-api.example.com/v1/chat/completions
# YO_API_TYPE=openai   # openai or anthropic

# Model variant / reasoning effort (opencode backend only)
# YO_VARIANT=
DEFAULTCONF
    echo "Created default config at $config_dir/config" >&2
  fi
  ${EDITOR:-vim} "$config_dir/config"
}
