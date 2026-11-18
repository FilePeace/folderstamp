#!/usr/bin/env bash
# Regression tests for the durable NUL-delimited snapshot manifest.
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
# Load Folderstamp functions without running its command-line dispatcher.
# shellcheck source=../folderstamp
source "$ROOT_DIR/folderstamp"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

source_dir="$tmp_dir/source"
work_dir="$tmp_dir/work"
mkdir -p "$source_dir" "$work_dir"

# Include ordinary, empty, and newline-containing filenames.
printf 'hello\\n' > "$source_dir/plain.txt"
: > "$source_dir/empty"
printf 'newline\\n' > "$source_dir/"$'line\nbreak'

(
    cd "$source_dir"
    build_snapshot_file_list non-recursive "$work_dir/files.list" "$work_dir"
)

metadata="$(snapshot_file_list_metadata "$work_dir/files.list")"
read -r list_bytes list_crc list_count <<< "$metadata"

[[ "$list_bytes" -gt 0 ]] || { echo "FAIL: manifest should not be empty" >&2; exit 1; }
[[ "$list_crc" =~ ^[0-9]+$ ]] || { echo "FAIL: checksum is not numeric" >&2; exit 1; }
[[ "$list_count" -eq 3 ]] || { echo "FAIL: expected 3 entries, got $list_count" >&2; exit 1; }

validate_snapshot_file_list "$work_dir/files.list" "$list_bytes" "$list_crc" "$list_count" || {
    echo "FAIL: freshly generated manifest did not validate" >&2
    exit 1
}

# A changed manifest must not pass the committed metadata check.
cp "$work_dir/files.list" "$work_dir/files.list.good"
printf 'X' | dd of="$work_dir/files.list" bs=1 seek=0 conv=notrunc 2>/dev/null
if validate_snapshot_file_list "$work_dir/files.list" "$list_bytes" "$list_crc" "$list_count"; then
    echo "FAIL: modified manifest was accepted" >&2
    exit 1
fi
mv "$work_dir/files.list.good" "$work_dir/files.list"

# A partial final pathname without its NUL terminator must be rejected.
printf 'unterminated-path' > "$work_dir/broken.list"
if snapshot_file_list_metadata "$work_dir/broken.list" >/dev/null 2>&1; then
    echo "FAIL: unterminated manifest was accepted" >&2
    exit 1
fi

# Empty manifests are valid and have a stable, verifiable representation.
: > "$work_dir/empty.list"
empty_metadata="$(snapshot_file_list_metadata "$work_dir/empty.list")"
read -r empty_bytes empty_crc empty_count <<< "$empty_metadata"
[[ "$empty_bytes" -eq 0 && "$empty_count" -eq 0 ]] || {
    echo "FAIL: empty manifest metadata is incorrect" >&2
    exit 1
}
validate_snapshot_file_list "$work_dir/empty.list" "$empty_bytes" "$empty_crc" "$empty_count" || {
    echo "FAIL: empty manifest did not validate" >&2
    exit 1
}

echo "PASS: durable manifest metadata, corruption detection, NUL boundary, and empty manifest"
