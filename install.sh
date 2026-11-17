#!/usr/bin/env sh
set -eu

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_dir() {
    uname_s="$(uname -s 2>/dev/null || echo unknown)"
    uname_o="$(uname -o 2>/dev/null || echo unknown)"
    prefix_value="${PREFIX:-}"

    if [ -n "${TERMUX_VERSION:-}" ] || [ "$prefix_value" != "${prefix_value#*com.termux}" ] || [ "$uname_o" = "Android" ]; then
        if [ -n "${PREFIX:-}" ]; then
            printf '%s/bin\n' "$PREFIX"
        else
            echo "Termux was detected, but PREFIX is not set. Start the installer inside Termux." >&2
            return 1
        fi
    elif [ "$uname_s" = "Redox" ]; then
        printf '%s/bin\n' "$HOME"
    elif [ "$uname_s" = "Darwin" ] || [ "${uname_s#CYGWIN}" != "$uname_s" ] || [ "${uname_s%BSD}" != "$uname_s" ]; then
        printf '%s/.local/bin\n' "$HOME"
    elif [ "$uname_s" = "Fuchsia" ] || [ "$uname_s" = "Zircon" ]; then
        printf '%s/bin\n' "$HOME"
    else
        printf '%s/.local/bin\n' "$HOME"
    fi
}

install_staged() {
    src="$1"
    dest="$2"
    dest_dir="$(dirname "$dest")"

    # Stage beside the destination so the final rename is on the same
    # filesystem. Preserve an existing installation before replacing it.
    mkdir -p "$dest_dir"
    tmp="$(mktemp "$dest_dir/.folderstamp.install.XXXXXX")"
    backup=""
    cleanup() {
        [ -z "$tmp" ] || rm -f "$tmp"
    }
    trap cleanup EXIT HUP INT TERM

    if ! cp "$src" "$tmp"; then
        echo "Could not stage folderstamp; existing installation was not changed." >&2
        return 1
    fi
    chmod 755 "$tmp"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup="$dest.backup.$(date +%Y%m%d%H%M%S 2>/dev/null || echo unknown)"
        if [ -e "$backup" ] || [ -L "$backup" ]; then
            echo "Backup path already exists: $backup" >&2
            return 1
        fi
        if ! mv "$dest" "$backup"; then
            echo "Could not preserve existing installation at $dest." >&2
            return 1
        fi
    fi

    if ! mv "$tmp" "$dest"; then
        if [ -n "$backup" ] && [ ! -e "$dest" ]; then
            mv "$backup" "$dest" || echo "WARNING: restore manually from $backup" >&2
        fi
        echo "Could not publish the new executable." >&2
        return 1
    fi
    tmp=""
    trap - EXIT HUP INT TERM
    echo "Installed executable: $dest"
    if [ -n "$backup" ]; then
        echo "Previous executable preserved at: $backup"
    fi
}

DEST_DIR="$(install_dir)"
DEST="$DEST_DIR/folderstamp"

echo "Installing folderstamp..."
echo "- Installing folderstamp command in $DEST_DIR..."
install_staged folderstamp "$DEST"
echo "folderstamp installed at $DEST"
