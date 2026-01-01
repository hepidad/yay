#!/bin/bash

# yay - YouTube search, playback, download, history, and more
# Version: 0.2.1

# Determine installation location
_YAY_SOURCE="${BASH_SOURCE[0]:-${(%):-%x}}"
# Fallback if detection fails (e.g. some shell contexts)
if [[ -z "$_YAY_SOURCE" ]]; then _YAY_SOURCE="$0"; fi
_YAY_HOME="$( cd "$( dirname "$_YAY_SOURCE" )" && pwd )"

yay() {
  local VERSION="0.2.1"
  local audio_only=false
  local times=-1
  local log_enabled=true
  local from_history=false
  local download_only=false
  local search_limit=30
  local query=()
  local history_filter=""

  local HISTORY_FILE="$HOME/.yay-history.log"

  # Parse arguments
  while [[ "$1" ]]; do
    case "$1" in
      -a)
        audio_only=true
        shift
        ;;
      -n)
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
        search_limit="$2"
        shift 2
        ;;
      -v|--version)
        echo "yay version $VERSION"
        return 0
        ;;
      --location)
        echo "$_YAY_HOME"
        return 0
        ;;
      --update)
        echo "⬇️ Checking for updates..."
        cd "$_YAY_HOME" || return 1
        if git pull; then
            echo "✅ Updated successfully."
            echo "⚠️ If you are using 'yay' as a shell function, please run: source $_YAY_SOURCE"
        else
            echo "❌ Update failed."
        fi
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

    local chosen url
    chosen=$(echo "$filtered" | tac | fzf --prompt="📜 Select from history: ")
    url=$(echo "$chosen" | awk -F' | ' '{print $NF}')

    if [[ -z "$url" ]]; then
      echo "❌ No video selected."
      return 1
    fi

    if $download_only; then
      echo "⬇️ Downloading from history..."
      if $audio_only; then
        yt-dlp -x --audio-format mp3 "$url"
      else
        yt-dlp "$url"
      fi
    else
      echo "🔁 Replaying: $url"
      if $audio_only; then
        mpv --no-video --term-osd-bar "$url"
      else
        mpv "$url"
      fi
    fi

    return 0
  fi

  # 🔍 Normal search + playback or download
  local search="${query[*]}"
  local urls chosen url title
  local count=0

  if [[ -z "$search" ]]; then
    echo "❌ Please provide a search query."
    return 1
  fi

  while [[ $times -lt 0 || $count -lt $times ]]; do
    urls=$(yt-dlp "ytsearch${search_limit}:$search" --print "%(title).50s (%(duration_string)s) - %(uploader)s | %(webpage_url)s")
    chosen=$(echo "$urls" | fzf --prompt="🎬 Pick a video (or Esc to auto-play top): " || echo "$urls" | head -n 1)
    url=$(echo "$chosen" | awk -F' | ' '{print $NF}')
    title=$(echo "$chosen" | awk -F' | ' '{print $1}')

    if [[ -z "$url" ]]; then
      echo "❌ No video selected. Exiting."
      break
    fi

    # Log history
    if $log_enabled; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $title | $url" >> "$HISTORY_FILE"
    fi

    if $download_only; then
      echo "⬇️ Downloading: $title"
      if $audio_only; then
        yt-dlp -x --audio-format mp3 "$url"
      else
        yt-dlp "$url"
      fi
    else
      if $audio_only; then
        mpv --no-video --term-osd-bar "$url"
      else
        mpv "$url"
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
