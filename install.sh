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

prompt_yes() {
    if [ ! -r /dev/tty ] || [ ! -w /dev/tty ]; then
        return 1
    fi
    local reply=""
    printf "%s [y/N] " "$1" > /dev/tty
    IFS= read -r reply < /dev/tty || true
    case "$reply" in
        [yY]*) return 0 ;;
        *) return 1 ;;
    esac
}

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

if command -v yt-dlp >/dev/null 2>&1 && prompt_yes "Update yt-dlp to the latest version now? (recommended, YouTube breaks old builds)"; then
    if command -v pipx >/dev/null 2>&1 && pipx list --short 2>/dev/null | grep -q '^yt-dlp '; then
        pipx upgrade yt-dlp
    elif command -v pip3 >/dev/null 2>&1; then
        pip3 install --user -U yt-dlp
    else
        $SUDO yt-dlp -U || echo "yt-dlp update failed, update it manually later"
    fi
fi

if [ "$EUID" -eq 0 ] && command -v systemctl >/dev/null 2>&1; then
    WORKDIR="/opt/yt-bot"
    mkdir -p "$WORKDIR"

    cat > /etc/systemd/system/yt-bot.service <<EOF
[Unit]
Description=yt-bot Telegram audio downloader
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=${WORKDIR}
Environment=PATH=${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=${DEST}/${BIN} serve
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable yt-bot.service
    echo "systemd service installed (not started)."
    echo "Put yt_bot_token.json and cookies.txt into ${WORKDIR}, then run: systemctl start yt-bot"
fi

echo "Done. Installed to ${DEST}/${BIN}"

for dep in yt-dlp ffmpeg; do
    command -v "$dep" >/dev/null 2>&1 || [ -x "$HOME/.local/bin/$dep" ] || \
        echo "WARNING: $dep not found in PATH"
done
command -v node >/dev/null 2>&1 || command -v deno >/dev/null 2>&1 || \
    echo "WARNING: no JS runtime (node/deno), some YouTube formats may be missing"

echo "If YouTube says 'Sign in to confirm you're not a bot', put cookies.txt (Netscape format) in the bot's working directory."
