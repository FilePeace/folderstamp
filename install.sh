#!/usr/bin/env sh
set -eu

command_exists() {
    command -v "$1" >/dev/null 2>&1
}


is_termux() {
    # Prefer Termux-provided environment markers so detection does not depend
    # on GNU coreutils being installed already.
    [ -n "${TERMUX_VERSION:-}" ] && return 0

    case "${PREFIX:-}" in
        *com.termux*) return 0 ;;
    esac

    [ -n "${TERMUX_APP__PACKAGE:-}" ] && return 0

    if command_exists uname; then
        uname_o="$(uname -o 2>/dev/null || echo unknown)"
        [ "$uname_o" = "Android" ] && return 0
    fi

    return 1
}

termux_command_exists() {
    # Do not mistake Android's /system/bin utilities for the Termux packages:
    # Folderstamp expects the Termux-provided Bash/coreutils/findutils tools.
    command_path="$(command -v "$1" 2>/dev/null || true)"
    case "$command_path" in
        "$PREFIX"/bin/*) return 0 ;;
    esac
    return 1
}

ensure_termux_dependencies() {
    if [ -z "${PREFIX:-}" ]; then
        echo "Termux was detected, but PREFIX is not set. Start this installer inside Termux." >&2
        return 1
    fi

    packages_to_install=""

    if ! termux_command_exists bash; then
        packages_to_install="$packages_to_install bash"
    fi

    # These representative commands are supplied by Termux's coreutils
    # package and cover both installer operations and Folderstamp's runtime.
    for utility in stat dirname mktemp; do
        if ! termux_command_exists "$utility"; then
            packages_to_install="$packages_to_install coreutils"
            break
        fi
    done

    if ! termux_command_exists find; then
        packages_to_install="$packages_to_install findutils"
    fi

    if [ -z "$packages_to_install" ]; then
        echo "Termux dependencies already available (bash, coreutils, findutils)."
        return 0
    fi

    if ! command_exists pkg; then
        echo "Termux was detected, but the 'pkg' package manager is unavailable." >&2
        echo "Install/repair Termux's package manager, then run this installer again." >&2
        return 1
    fi

    echo "Termux detected. Installing missing dependencies:$packages_to_install"
    if ! pkg update; then
        echo "Termux package index update failed; no existing Folderstamp installation was changed." >&2
        return 1
    fi

    # This list contains only fixed package names assembled above.
    # shellcheck disable=SC2086
    set -- $packages_to_install
    if ! pkg install -y "$@"; then
        echo "Could not install the required Termux packages; no existing Folderstamp installation was changed." >&2
        return 1
    fi

    for utility in bash stat dirname mktemp find; do
        if ! termux_command_exists "$utility"; then
            echo "Required Termux command is still unavailable after package installation: $utility" >&2
            return 1
        fi
    done
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

if is_termux; then
    ensure_termux_dependencies
fi

DEST_DIR="$(install_dir)"
DEST="$DEST_DIR/folderstamp"

echo "Installing folderstamp..."
echo "- Installing folderstamp command in $DEST_DIR..."
install_staged folderstamp "$DEST"
echo "folderstamp installed at $DEST"
