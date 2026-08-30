#!/bin/bash

# yay - YouTube search, playback, download, history, and more

# Determine installation location
_YAY_SOURCE="${BASH_SOURCE[0]:-${(%):-%x}}"
if [[ -z "$_YAY_SOURCE" ]]; then _YAY_SOURCE="$0"; fi
_YAY_HOME="$( cd "$( dirname "$_YAY_SOURCE" )" && pwd )"

# Fix #11: Single source of truth for version
_YAY_VERSION="0.2.4"

# Fix #12: Extract playback logic into helper function
_yay_play() {
  local url="$1" title="$2" audio_only="$3"
  local ytdlp_rc mpv_rc
  if $audio_only; then
    yt-dlp --quiet --no-warnings -o - "$url" | mpv --title="$title" --no-video --term-osd-bar -
  else
    yt-dlp --quiet --no-warnings -o - "$url" | mpv --title="$title" -
  fi
  ytdlp_rc=${PIPESTATUS[0]}
  mpv_rc=${PIPESTATUS[1]:-$?}

  # If yt-dlp exited with a genuine error (not SIGPIPE 141 from quitting mpv early),
  # it's most likely a YouTube extraction failure such as HTTP 403 Forbidden.
  # These break when yt-dlp is outdated — remind the user to update it.
  if [[ $ytdlp_rc -ne 0 && $ytdlp_rc -ne 141 ]]; then
    echo "⚠️ yt-dlp couldn't fetch this video (possible YouTube block / HTTP 403)."
    echo "   YouTube changes often break older yt-dlp versions. Try updating it:"
    echo "     brew upgrade yt-dlp"
  fi

  return $mpv_rc
}

_yay_download() {
  local url="$1" audio_only="$2"
  if $audio_only; then
    yt-dlp --no-warnings -x --audio-format mp3 "$url"
  else
    yt-dlp --no-warnings "$url"
  fi
}

# Migrate old history format (" | " delimiter) to new tab-delimited format
_yay_migrate_history() {
  local hfile="$1"
  [[ -f "$hfile" ]] || return 0
  # Skip if already migrated (first line contains a tab)
  head -n 1 "$hfile" | grep -q $'\t' && return 0
  # Convert: [timestamp] title | url  →  [timestamp] title\turl
  local tmp="${hfile}.mig"
  sed "s/ | \(https\{0,1\}:\/\/[^ ]*\)$/$(printf '\t')\1/" "$hfile" > "$tmp" && mv "$tmp" "$hfile"
}

yay() {
  local audio_only=false
  local times=-1
  local log_enabled=true
  local from_history=false
  local download_only=false
  local search_limit=30
  local query=()
  local history_filter=""

  local HISTORY_FILE="$HOME/.yay-history.log"

  # Migrate old history format on first run
  _yay_migrate_history "$HISTORY_FILE"

  # Fix #4: Dependency check
  local dep
  for dep in yt-dlp fzf mpv; do
    command -v "$dep" &>/dev/null || { echo "❌ Missing dependency: $dep (brew install $dep)"; return 1; }
  done

  # Parse arguments
  while [[ "$1" ]]; do
    case "$1" in
      -a)
        audio_only=true
        shift
        ;;
      -n)
        # Fix #5: Validate -n argument
        if [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]]; then
          echo "❌ -n requires a positive numeric argument."; return 1
        fi
        times="$2"
        shift 2
        ;;
      -l|--no-log)
        log_enabled=false
        shift
        ;;
      -h|--history)
        from_history=true
        shift
        if [[ "$1" && "$1" != "-"* ]]; then
          history_filter="$1"
          shift
        fi
        ;;
      -d)
        download_only=true
        shift
        ;;
      -r)
        if [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]]; then
          echo "❌ -r requires a numeric argument."; return 1
        fi
        search_limit="$2"
        shift 2
        ;;
      -v|--version)
        echo "yay version $_YAY_VERSION"
        return 0
        ;;
      --location)
        echo "$_YAY_HOME"
        return 0
        ;;
      # Fix #1: --update uses subshell to avoid changing cwd
      --update)
        echo "⬇️ Checking for updates..."
        if (cd "$_YAY_HOME" && git pull); then
          echo "✅ Updated successfully."
          echo "⚠️ If you are using 'yay' as a shell function, please run: source $_YAY_SOURCE"
        else
          echo "❌ Update failed."
        fi
        return 0
        ;;
      # Fix #7: Add --help flag
      --help)
        cat <<EOF
yay v$_YAY_VERSION — YouTube search + playback from your terminal

Usage: yay [options] <search query>

Options:
  -a              Audio-only playback
  -n <count>      Loop playback N times (default: infinite)
  -r <count>      Number of search results (default: 30)
  -d              Download instead of play
  -l, --no-log    Disable history logging
  -h, --history   Browse/replay from history
  -v, --version   Show version
  --location      Show install path
  --update        Self-update via git pull
  --help          Show this help

Examples:
  yay lofi beats          Search and play
  yay -a -n 3 jazz        Audio-only, 3 loops
  yay -d nature sounds    Download top pick
  yay -h                  Replay from history
EOF
        return 0
        ;;
      *)
        query+=("$1")
        shift
        ;;
    esac
  done

  # ♻️ History Replay or Download
  if $from_history; then
    if [[ ! -f "$HISTORY_FILE" ]]; then
      echo "❌ No history file found at $HISTORY_FILE"
      return 1
    fi

    echo "📜 Reading history from: $HISTORY_FILE"
    local filtered=""
    if [[ -n "$history_filter" ]]; then
      filtered=$(grep -i "$history_filter" "$HISTORY_FILE")
      if [[ -z "$filtered" ]]; then
        echo "⚠️ No history entries found for: $history_filter"
        return 1
      fi
    else
      filtered=$(cat "$HISTORY_FILE")
    fi

    # Fix #8: Deduplicate history on display (keep latest occurrence)
    local chosen url title
    chosen=$(echo "$filtered" | tac | awk -F'\t' '!seen[$2]++' | fzf --prompt="📜 Select from history: ")
    # Fix #3: Use tab delimiter for parsing
    url=$(echo "$chosen" | awk -F'\t' '{print $2}')
    title=$(echo "$chosen" | awk -F'\t' '{print $1}' | sed 's/^\[[^]]*\] //')

    if [[ -z "$url" ]]; then
      echo "❌ No video selected."
      return 1
    fi

    if $download_only; then
      echo "⬇️ Downloading from history: $title"
      # Fix #10: Print download destination
      echo "📂 Saving to: $(pwd)"
      _yay_download "$url" "$audio_only"
    else
      echo "🔁 Replaying: $title"
      _yay_play "$url" "$title" "$audio_only"
    fi

    return 0
  fi

  # 🔍 Normal search + playback or download
  local search="${query[*]}"
  local urls chosen url title
  local count=0

  if [[ -z "$search" ]]; then
    echo "❌ Please provide a search query. See: yay --help"
    return 1
  fi

  # Fix #9: Fetch search results once, outside the loop
  urls=$(yt-dlp --no-warnings "ytsearch${search_limit}:$search" --print "%(title).50s (%(duration_string)s) - %(uploader)s\t%(webpage_url)s")

  # Fix #6: Handle empty search results
  if [[ -z "$urls" ]]; then
    echo "❌ No results found for: $search"
    return 1
  fi

  while [[ $times -lt 0 || $count -lt $times ]]; do
    # fzf exit codes: 0=selected, 1=no match, 130=Ctrl+C, other=Esc
    chosen=$(echo "$urls" | awk -F'\t' '{print $1 " | " $2}' | fzf --prompt="🎬 Pick a video (Esc=play top, Ctrl+C=quit): ")
    local fzf_rc=$?

    # Ctrl+C in fzf → quit entirely
    if [[ $fzf_rc -eq 130 ]]; then
      echo "⛔ Interrupted."
      break
    fi

    # Esc in fzf (exit 1) → auto-play top result
    if [[ -z "$chosen" ]]; then
      chosen=$(echo "$urls" | awk -F'\t' '{print $1 " | " $2}' | head -n 1)
    fi

    url=$(echo "$chosen" | awk -F' \\| ' '{print $NF}')
    title=$(echo "$chosen" | awk -F' \\| ' '{$NF=""; sub(/ *$/, ""); print}')

    if [[ -z "$url" ]]; then
      echo "❌ No video selected. Exiting."
      break
    fi

    # Fix #3: Log with tab delimiter
    if $log_enabled; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $title"$'\t'"$url" >> "$HISTORY_FILE"
    fi

    if $download_only; then
      echo "⬇️ Downloading: $title"
      # Fix #10: Print download destination
      echo "📂 Saving to: $(pwd)"
      _yay_download "$url" "$audio_only"
    else
      _yay_play "$url" "$title" "$audio_only"
      # If mpv was killed by Ctrl+C (exit 130) or SIGPIPE (141), break out
      local rc=$?
      if [[ $rc -eq 130 || $rc -eq 141 || $rc -eq 4 ]]; then
        echo ""
        echo "⛔ Interrupted."
        break
      fi
    fi

    ((count++))
  done

  echo "✅ Done. $count item(s) processed."
  if $log_enabled; then
    echo "📝 History saved to: $HISTORY_FILE"
  else
    echo "🚫 Logging disabled."
  fi
}

# Execute if not sourced
if ! (return 0 2>/dev/null); then
    yay "$@"
fi
