# yt-bot

A Telegram bot and CLI tool to download YouTube audio as MP3.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/<USER>/<REPO>/master/install.sh | bash
```

## Requirements

* C++20 compatible compiler (GCC 13+ / Clang 16+)
* CMake 3.16+
* `libcurl4-openssl-dev` and `libssl-dev`
* `yt-dlp` and `ffmpeg` (available in `PATH`)

### Install Dependencies (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install -y cmake build-essential libcurl4-openssl-dev libssl-dev ffmpeg
pip install yt-dlp  # or via your system package manager
```

## Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
```

The compiled binary will be placed at `build/yt_bot`.

## Usage

### 1. CLI Download

```bash
./build/yt_bot https://www.youtube.com/watch?v=...
```

Saves the track to the current directory as `<title>.mp3`.

### 2. Telegram Bot Mode

Run `serve` to generate a configuration template `yt_bot_token.json`:

```bash
./build/yt_bot serve
```

Edit the generated file with your credentials:

```json
{
    "bot": {
        "token": "123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
    },
    "channel": {
        "token": "@your_channel_name"
    }
}
```

* `channel.token`: Optional channel username or ID to forward downloaded audio to (leave as `""` if not needed).

Start the bot:

```bash
./build/yt_bot serve
```
