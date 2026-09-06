#!/usr/bin/env bash
set -e

REPO="${NoNFake/yt-bot}"
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

echo "Done. Installed to ${DEST}/${BIN}"
