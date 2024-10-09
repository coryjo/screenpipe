# Screenpipe Command Reference

## Usage
```
screenpipe [OPTIONS] [COMMAND]
```

### Commands
- **pipe**: Pipe management commands.
- **help**: Print this message or the help of a given subcommand.

## Options

### General Settings
- `-h, --help`
  - Print help.
- `-V, --version`
  - Print version.
- `--debug`
  - Enable debug logging for screenpipe modules.
- `--disable-telemetry`
  - Disable telemetry.
- `--enable-llm`
  - Enable Local LLM API.

### Screen Recording
- `-f, --fps <FPS>`
  - Set frames per second for continuous recording.
  - Example: 1 FPS = 30 GB/month, 5 FPS = 150 GB/month.
  - **Optimize according to needs.** Your screen rarely changes more than once per second, right? [default: 0.2]
- `--list-monitors`
  - List available monitors.
  - Use `--monitor-id` to select one (with the ID).
- `-m, --monitor-id <MONITOR_ID>`
  - Select monitors to record.
- `--ignored-windows <IGNORED_WINDOWS>`
  - List of windows to ignore during screen recording (matched by title).
  - Example: `--ignored-windows "Spotify"` will ignore "Spotify", `--ignored-windows "Bit"` will ignore both "Bitwarden" and "Bittorrent".
- `--included-windows <INCLUDED_WINDOWS>`
  - List of windows to include during screen recording (matched by title).
  - Example: `--included-windows "Chrome"` will include "Google Chrome".
- `--disable-vision`
  - Disable vision recording.
- `--use-pii-removal`
  - Enable PII removal from OCR text saved to the database or returned in search results.

### Audio Recording
- `-d, --audio-chunk-duration <AUDIO_CHUNK_DURATION>`
  - Set audio chunk duration in seconds [default: 30].
- `--disable-audio`
  - Disable audio recording.
- `-i, --audio-device <AUDIO_DEVICE>`
  - Specify audio devices (can be specified multiple times).
- `--list-audio-devices`
  - List available audio devices.
- `-a, --audio-transcription-engine <AUDIO_TRANSCRIPTION_ENGINE>`
  - Choose the audio transcription engine:
    - `deepgram`: High-quality cloud-based service (free of charge).
    - `whisper-tiny`: Lightweight, local model for high privacy.
    - `whisper-large`: Local model for better quality [default: whisper-large].
  - **Possible values**: deepgram, whisper-tiny, whisper-large.
- `--vad-engine <VAD_ENGINE>`
  - Voice Activity Detection (VAD) engine [default: silero].
  - **Possible values**: webrtc, silero.
- `--vad-sensitivity <VAD_SENSITIVITY>`
  - Set VAD sensitivity level [default: high].
  - **Possible values**: low, medium, high.
- `--deepgram-api-key <DEEPGRAM_API_KEY>`
  - Deepgram API key for audio transcription.

### OCR (Optical Character Recognition)
- `-o, --ocr-engine <OCR_ENGINE>`
  - Choose the OCR engine:
    - `apple-native`: Default for macOS.
    - `windows-native`: Local engine for Windows.
    - `unstructured`: Cloud-based engine for high-quality OCR (free of charge).
    - `tesseract`: Local engine (not supported on macOS) [default: apple-native].
  - **Possible values**: unstructured, apple-native.

### Video Management
- `--video-chunk-duration <VIDEO_CHUNK_DURATION>`
  - Set video chunk duration in seconds [default: 60].

### Server Settings
- `-p, --port <PORT>`
  - Port to run the server on [default: 3030].
- `--data-dir <DATA_DIR>`
  - Set data directory (defaults to `$HOME/.screenpipe`).

### Miscellaneous
- `--friend-wearable-uid <FRIEND_WEARABLE_UID>`
  - UID key for sending data to a friend's wearable (optional).
- `--auto-destruct-pid <AUTO_DESTRUCT_PID>`
  - PID to watch for auto-destruction. Screenpipe stops when the PID is no longer running.
- `--save-text-files`
  - Save text files.

---
This reference aims to provide an overview of the available commands and options in Screenpipe, making it easier for users to configure their recording needs.

