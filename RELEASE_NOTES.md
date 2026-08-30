# Release Notes

## v0.2.4 (2026-08-30)

### ✨ Improvements
- **yt-dlp update hint on playback failure**: When `yt-dlp` fails to fetch a stream due to a genuine extraction error (e.g. `HTTP 403 Forbidden`), `yay` now prints a clear hint to run `brew upgrade yt-dlp`. Normal early quits (pressing `q` in mpv, which sends SIGPIPE to `yt-dlp`) are excluded so the hint only fires on real failures.

## v0.2.3 (2026-07-25)

### 🐛 Bug Fixes
- **`--update` cd bug**: Self-update no longer changes the user's working directory. The `git pull` now runs in a subshell.
- **Esc fallback in fzf**: Pressing Esc now correctly auto-plays the top result instead of exiting with nothing.
- **Ctrl+C now exits properly**: Ctrl+C in the fzf playlist screen exits immediately back to terminal. Ctrl+C during playback kills mpv and breaks out of the loop instead of looping back to the playlist.
- **History parsing**: Switched from ` | ` to tab delimiter to avoid conflicts with `|` in video titles.
- **`-n` validation**: The `-n` flag now rejects non-numeric input instead of silently breaking.

### ✨ Improvements
- **Dependency check**: `yay` now checks for `yt-dlp`, `fzf`, and `mpv` at startup and shows a clear error if any are missing.
- **Empty search handling**: Shows a clear error when `yt-dlp` returns no results instead of opening an empty fzf list.
- **`--help` flag**: Added a built-in usage summary with all options and examples.
- **History deduplication**: History replay now shows only the latest occurrence of each video.
- **Cached search results**: Search results are fetched once and reused across loop iterations instead of re-querying YouTube every cycle.
- **Download destination**: Downloads now print the output directory (`📂 Saving to: ...`).

### 🔧 Internal
- **Single version source**: Version is now defined once as `_YAY_VERSION` at the top level.
- **Helper functions**: Extracted `_yay_play` and `_yay_download` to eliminate duplicated playback/download logic.
- **History migration**: Old history files using ` | ` as delimiter are automatically migrated to tab-delimited format on first run.

---

## v0.2.2 (2026-02-13)

### 🐛 Bug Fixes
- **Playback Fix**: Resolved `HTTP 403 Forbidden` errors by switching to `yt-dlp` stdout piping to `mpv`. This bypasses YouTube's recent blocking of direct playback URLs.

### ✨ Improvements
- **Better UX**: Added video title support to `mpv` player, so the window title now displays the actual video name instead of a generic input name.
- **History Replay**: Updated history replay to correctly parse and pass titles to the player.

## v0.2.1 (2026-01-01)

### ✨ Improvements
- **Audio Progress Bar**: Added a progress bar for audio-only mode (`-a`) using `mpv --term-osd-bar`.
- **Optimized Search Display**: Reduced title length to ensure the Video URL is visible in the list.
- **Self Update**: Added `--update` flag to easily pull the latest changes from the repository.
- **Better Sourcing**: Fixed an issue where the script would execute immediately upon sourcing (e.g., in `.zshrc`). It now correctly waits for explicit invocation unless run as a standalone script.

---

## v0.2.0 (2025-12-17)

### ✨ New Features
- **Configurable Search Limit**: You can now specify how many results to fetch using the `-r` flag (e.g., `yay -r 10 query`).
- **Increased Default Results**: The default search result limit has been increased from 10 to 30.
- **Version Info**: Added `--version` / `-v` flag to check the current installed version.
- **Location Info**: Added `--location` flag to show where `yay` is installed/located.
- **Standalone Execution**: `yay` can now be run as a standalone script (e.g., via symlink in `/usr/local/bin`) in addition to being sourced.

### 📚 Documentation
- Updated README with installation instructions for system-wide usage (symlink).
- Added "Update" section to README.
- Documented new flags (`-r`, `--version`, `--location`).

---

## v0.1.0 (Initial Release)

- Basic YouTube search and playback.
- Interactive selection with `fzf`.
- Video and Audio-only modes.
- History tracking and replay.
- Loop/Repeat functionality.
