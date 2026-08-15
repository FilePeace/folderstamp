#!/bin/sh
set -e

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_dir() {
    uname_s="$(uname -s 2>/dev/null || echo unknown)"
    uname_o="$(uname -o 2>/dev/null || echo unknown)"

    if [ -n "${TERMUX_VERSION:-}" ] || [ "${PREFIX:-}" != "${PREFIX#*com.termux}" ] || [ "$uname_o" = "Android" ]; then
        echo "${PREFIX:-/data/data/com.termux/files/usr}/bin"
    elif [ "$uname_s" = "Redox" ]; then
        echo "${HOME}/bin"
    elif [ "$uname_s" = "Darwin" ]; then
        echo "/usr/local/bin"
    elif [ "${uname_s#CYGWIN}" != "$uname_s" ]; then
        echo "/usr/local/bin"
    elif [ "${uname_s%BSD}" != "$uname_s" ]; then
        echo "/usr/local/bin"
    elif [ "$uname_s" = "Fuchsia" ] || [ "$uname_s" = "Zircon" ]; then
        echo "${HOME}/bin"
    else
        echo "/usr/bin"
    fi
}

copy_as_needed() {
    src="$1"
    dest="$2"

    if [ -w "$(dirname "$dest")" ]; then
        cp -f "$src" "$dest"
    elif command_exists sudo; then
        sudo cp -f "$src" "$dest"
    else
        echo "Cannot write to $(dirname "$dest") and sudo is unavailable." >&2
        echo "Try: install -Dm755 folderstamp \"$dest\"" >&2
        exit 1
    fi
}

chmod_as_needed() {
    dest="$1"

    if [ -w "$dest" ]; then
        chmod +x "$dest"
    elif command_exists sudo; then
        sudo chmod +x "$dest"
    else
        echo "Cannot chmod $dest and sudo is unavailable." >&2
        exit 1
    fi
}

DEST_DIR="$(install_dir)"
DEST="$DEST_DIR/folderstamp"

mkdir -p "$DEST_DIR" 2>/dev/null || true

echo "Installing folderstamp..."
echo "- Installing folderstamp command in $DEST_DIR..."
copy_as_needed folderstamp "$DEST"
echo "- Turning folderstamp into an executable..."
chmod_as_needed "$DEST"
echo "folderstamp installed at $DEST"
