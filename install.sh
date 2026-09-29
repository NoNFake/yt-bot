#!/usr/bin/env bash
set -e

REPO="${REPO:-NoNFake/yt-bot}"
BIN="yt_bot"
DEST="${INSTALL_DIR:-/usr/local/bin}"

if [ ! -w "$DEST" ] && [ "$EUID" -ne 0 ]; then
    DEST="$HOME/.local/bin"
    mkdir -p "$DEST"
fi

URL="https://github.com/${REPO}/releases/latest/download/${BIN}"

echo "Downloading ${BIN} from ${REPO} to ${DEST}..."
curl -fL# "$URL" -o "${DEST}/${BIN}"
chmod +x "${DEST}/${BIN}"

SUDO=""
if [ "$EUID" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    PKGS=""
    command -v ffmpeg >/dev/null 2>&1 || PKGS="$PKGS ffmpeg"
    command -v node >/dev/null 2>&1 || PKGS="$PKGS nodejs"
    if [ -n "$PKGS" ]; then
        echo "Installing:${PKGS}"
        $SUDO apt-get update -qq
        $SUDO apt-get install -y $PKGS
    fi
fi

if ! command -v yt-dlp >/dev/null 2>&1; then
    if command -v pipx >/dev/null 2>&1; then
        pipx install yt-dlp
    elif command -v pip3 >/dev/null 2>&1; then
        pip3 install --user yt-dlp
    elif command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get install -y yt-dlp
    fi
fi

echo "Done. Installed to ${DEST}/${BIN}"

for dep in yt-dlp ffmpeg; do
    command -v "$dep" >/dev/null 2>&1 || echo "WARNING: $dep not found in PATH"
done
command -v node >/dev/null 2>&1 || command -v deno >/dev/null 2>&1 || \
    echo "WARNING: no JS runtime (node/deno), some YouTube formats may be missing"

echo "If YouTube says 'Sign in to confirm you're not a bot', put cookies.txt (Netscape format) in the bot's working directory."
