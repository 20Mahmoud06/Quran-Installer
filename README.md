# 📖 Quran Downloader GUI

A simple, elegant desktop application built with **PyQt6** that lets you download high-quality Quran recitations (MP3) from your favorite reciters — with a single click.

The interface is fully in **Arabic** and laid out **right-to-left (RTL)** for a natural, native experience.

![App Screenshot](screenshot.png)

---

## ✨ Features / Benefits

- 🎙️ **241 Reciters (Qaris) built in** — one of the largest built-in reciter libraries around, covering globally famous names (Al-Afasy, Al-Husary, Al-Minshawi, and more) as well as many lesser-known but beloved reciters, each linked to a reliable streaming source.
- 🔍 **Searchable dropdowns** — both the reciter and Surah selectors support live autocomplete/filtering, so you can just start typing to find what you need instead of scrolling through long lists.
- 📚 **Full Mushaf download** — download all 114 Surahs from a chosen reciter in one click.
- 🎯 **Single Surah download** — or just grab one specific Surah if that's all you need.
- 📊 **Real-time progress tracking** — a progress bar plus live status text shows:
  - Current Surah being downloaded (e.g. `3/114`)
  - Percentage complete
  - Estimated time remaining (ETA)
- ⚡ **Non-blocking UI** — downloads run on a background thread (`QThread`), so the app never freezes while files are being fetched.
- 🔁 **Smart skip / resume-friendly** — if a file has already been downloaded (checked by filename), the app automatically skips it instead of re-downloading, so you can safely stop and restart a full-Mushaf download at any time.
- 🗂️ **Organized, human-readable file names** — files are saved as `NNN - SurahName.mp3` inside a folder named after the reciter, so your library stays clean and easy to browse.
- 🛡️ **Error resilience** — if a single Surah fails to download (e.g. network hiccup), the app logs the error and continues with the rest of the queue instead of crashing.
- 🎨 **Clean, modern look** — uses Qt's "Fusion" style for a consistent, native-feeling UI.
- 🖥️ **Standalone executable** — no Python, no dependencies, no setup. Just download and run.

---

## 🖼️ How It Works

1. **Search and select a reciter** from the dropdown (autocomplete included).
2. **Choose a download mode:**
   - "Download the entire Mushaf" (all 114 Surahs), or
   - "Download a specific Surah only"
3. If downloading a single Surah, **search and select** it from the Surah list.
4. Click **"Start One-Click Download"**.
5. Watch the **progress bar and status label** update live as files download.
6. Once finished, you'll get a confirmation popup with the exact folder path where your files were saved.

Downloaded files are saved to:
```
~/Downloads/Quran_Downloads/<Reciter_Name>/
```

---

## 🚀 Usage

No installation or setup needed — this is a **standalone executable**.

1. Download the latest `.exe` from the [Releases](../../releases) section.
2. Double-click to run it. That's it.

---

## 📁 Project Structure

```
quran_downloader_gui.exe   # Standalone app — download & run
quran_downloader_gui.py    # Source code (Python + PyQt6), for reference/building from source
```

The source is fully self-contained in a single file:
- `SURAHS` — list of all 114 Surah names in Arabic.
- `RECITERS` — dictionary mapping reciter names to their audio server base URLs.
- `DownloadWorker` — background `QThread` responsible for downloading files without freezing the UI.
- `QuranDownloaderApp` — the main PyQt6 window and UI logic.

---

## ⚠️ Notes

- No Python or dependencies required — just run the `.exe`.
- An internet connection is required to download recitations.
- Audio files are streamed from third-party public Quran audio servers; availability depends on those servers being online.
- This tool is intended for personal, offline listening convenience.

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome! Feel free to open an issue or submit a pull request.

## 📄 License

Specify your preferred license here (e.g., MIT).
