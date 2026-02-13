# Release Notes

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
