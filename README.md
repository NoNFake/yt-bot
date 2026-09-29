# yt-bot

A Telegram bot and CLI tool to download YouTube audio as MP3.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/NoNFake/yt-bot/master/install.sh | bash
```

## Requirements

* C++20 compatible compiler (GCC 13+ / Clang 16+)
* CMake 3.16+
* `libcurl4-openssl-dev` and `libssl-dev`
* `yt-dlp` and `ffmpeg` (available in `PATH`)
* a JS runtime for YouTube (`node` or `deno`)

The install script installs missing `yt-dlp`, `ffmpeg` and `nodejs` automatically (APT / pipx / pip).

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
yt_bot https://www.youtube.com/watch?v=...
```

Saves the track to the current directory as `<title>.mp3`.

### 2. Telegram Bot Mode

Run `serve` to generate a configuration template `yt_bot_token.json`:

```bash
yt_bot serve
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
yt_bot serve
```

### 3. Cookies (server / VPS)

YouTube often blocks datacenter IPs with `Sign in to confirm you're not a bot`. Fix: give the bot cookies.

1. In your local browser install the "Get cookies.txt LOCALLY" extension.
2. Export cookies for `youtube.com` in Netscape format.
3. Put the file as `cookies.txt` in the bot's working directory (same place as `yt_bot_token.json`).

The bot picks `cookies.txt` up automatically when it exists. Cookies expire after months; re-export when downloads start failing.

If `yt_bot serve` runs in a directory without write access to `cookies.txt` or the config, move the bot to a dedicated directory first.
