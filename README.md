# yay
> **Yet another interactive YouTube search + playback from your terminal. **
> Powered by `yt-dlp`, `fzf`, and `mpv`.

Search YouTube, pick videos with arrow keys, play in your terminal — audio or video — and now, loop the experience as many times as you want.

---

## ✨ Features

- 🔍 Search YouTube directly from the terminal
- 🎬 Browse top 10 results
- ⏯️ Play video or audio-only
- 🔁 Repeat selection N times (or infinitely)
- ⌨️ Keyboard-based selection (no mouse needed)
- 🚀 Fast and minimal setup
- And more importantly, no f*cking ads!

---

## 🛠 Requirements

Install dependencies using [Homebrew](https://brew.sh/):

```bash
brew install yt-dlp fzf mpv
```

## 📦 Installation
1. Clone the repo
```bash
git clone https://github.com/hepidad/yay.git
cd yay
```

2. Load the function in your shell
For Zsh:
```bash
echo 'source /full/path/to/yay/yay.sh' >> ~/.zshrc
source ~/.zshrc
```

For Bash:
```bash
echo 'source /full/path/to/yay/yay.sh' >> ~/.bash_profile
source ~/.bash_profile
```

## 🚀 Usage
1. Basic video search
```bash
yay nature sound
```

- Shows top 10 YouTube results for “nature sound”
- Press arrow keys to select a result, or Esc to play the top result.
- Loops forever until you quit (Ctrl+C)
- Enable logging/history.

2. Play audio-only:
```bash
yay -a nature sound
```

3. Loop n times
```bash
yay -n 3 nature sound
```

4. Loop n times and audio only
```bash
yay -a -n 3 nature sound
```

5. By default, logging is enabled. To pause logging:
```bash
yay -l nature sound
```

## Other Tips!
yay using the power of yt-dlp this mean you can:
1. Download video. For an example:
```bash
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID"
```
2. Download audio. For an example:
```bash
yt-dlp -x --audio-format mp3 "https://www.youtube.com/watch?v=VIDEO_ID"
```
3. Save into specific directory
```bash
yt-dlp -P /path/to/folder "https://www.youtube.com/watch?v=VIDEO_ID" 
```
4. Best Quality
```bash
yt-dlp -f bestvideo+bestaudio "https://www.youtube.com/watch?v=VIDEO_ID" 
```
  
## 📝 License
MIT — feel free to fork and improve!



