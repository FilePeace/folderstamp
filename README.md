# Folderstamp

Folderstamp creates a human-readable snapshot of regular files in the current directory. It records filesystem metadata and, when an available provider supports it, a content identifier (CID).

## Requirements

- Bash 4+ (the script is written for Bash, not POSIX sh).
- `stat` for file metadata. The standard Termux bootstrap normally includes `coreutils`, which provides `stat`; if it is missing, install/restore it with `pkg install coreutils`.
- `readlink` to display symbolic-link targets (optional; without it, the link metadata is still shown).
- `sync` and `wc` for durable checkpoint/resume support when using `save`.
- `find` for recursive mode.
- `df` and `awk` are optional and used for storage diagnostics.
- BLAKE3-256 content digests are calculated with `b3sum`, using streaming input rather than loading whole files into memory.
- When `b3sum` is missing, Folderstamp attempts to install the `b3sum` package with `apt` on Debian/Ubuntu or `pkg` on Termux. If installation fails, metadata snapshots still work without a content digest.
- The BLAKE3 digest uses the same BLAKE3-256 content-hash profile used by Iroh blobs. Folderstamp does not call Iroh's blob-add operation and does not store content in Iroh, Kubo, or another node.
- CIDv1/raw/BLAKE3 wrapping is temporarily not emitted. The Python implementations are disabled while a native Bash-compatible encoder is planned in `to-do.md`.
- Iroh and Kubo remain optional tools for future/manual validation only; neither is part of the snapshot hashing path.
- Folderstamp does not require Git, Gitoxide, Pijul, Iroh, Python, or Kubo merely to list file metadata. If `b3sum` cannot be installed, metadata is still recorded without the content digest.

## Install

### Termux

Install Bash and the core utilities from the Termux package manager:

```sh
pkg update
pkg install bash coreutils findutils
```

Then install from a cloned repository:

```sh
git clone https://github.com/FilePeace/folderstamp.git
cd folderstamp
bash install.sh
```

The installer targets `$PREFIX/bin` in Termux. It does not use `sudo`.

### Other Unix-like systems

```sh
git clone https://github.com/FilePeace/folderstamp.git
cd folderstamp
sh install.sh
```

The installer uses a user-writable bin directory where practical. Add that directory to `PATH` if your shell does not already include it.

## Usage

Run from the directory you want to inspect:

```sh
folderstamp display
folderstamp display --recursive
folderstamp save
folderstamp save --recursive
folderstamp resume .meta/folderstamp/.folderstamp.incomplete.ABC123/folderstamp.incomplete
folderstamp --help
```

- `display` writes the snapshot to standard output.
- `save` stores a completed snapshot under `.meta/folderstamp/`.
- A save is created in a dedicated workspace with a `folderstamp.incomplete` file and a checkpoint. After every completed file entry, the output and checkpoint are synced before progress advances.
- If the process fails or the device loses power, the `.incomplete` file and its checkpoint are kept. Folderstamp does not discard partial work.
- Resume by passing the selected `folderstamp.incomplete` path to `folderstamp resume PATH`. Resume from the original directory. The saved file list preserves the original traversal order; do not modify the source tree before resuming.
- On resume, bytes beyond the last durable checkpoint are truncated and the current uncommitted entry is regenerated. If the incomplete file is shorter than the checkpoint, Folderstamp refuses to guess or discard data.
- Existing completed snapshots are rotated to the next available name and are not intentionally overwritten.

## Included and excluded paths

- Regular files are included.
- Hidden files are included in both recursive and non-recursive modes.
- Symbolic links are recorded as links: `stat` metadata and the link target are displayed, including for dangling links. The link target is never traversed, and no content hash is calculated for a symlink.
- Git, Pijul, Mercurial, and Subversion metadata directories are pruned.
- Folderstamp's own metadata directory and legacy `.folderstamp*` files are excluded.
- `.folderstampignore` supports a deliberately limited gitignore-like pattern syntax. It is not a complete implementation of Git's ignore engine.

## Safety behavior

- A saved snapshot is generated in a unique temporary file inside the metadata directory.
- The final numbered filename is published only after generation succeeds.
- Existing snapshot files are not opened for truncation.
- A legacy root-level `.folderstamp` is migrated only when it is a regular file. Symlinks and special files cause a safe refusal.
- The installer stages the new executable beside its destination and preserves an existing installation in a timestamped backup before replacing it.
- Release-installed helper binaries use the same backup-before-replace approach.

These measures reduce accidental clobbering and preserve recoverable work after interruption. They are not a substitute for backups, and simultaneous writers on unusual network filesystems may still have filesystem-specific semantics.

## BLAKE3 digests and CIDv1 roadmap

- The snapshot path uses `b3sum` as its only content-digest engine. It reads each file through standard input, allowing streaming operation and avoiding filename parsing issues.
- The resulting 32-byte BLAKE3-256 digest is the content-hash profile used by Iroh blobs. Folderstamp does not invoke `iroh blobs add`, `ipfs add`, or any operation that stores file content in a local node.
- Python-based CIDv0/CIDv1 methods are disabled. The snapshot currently displays the BLAKE3 digest, not a CID.
- Implementing the CIDv1/raw/BLAKE3 encoder directly in Bash is a tracked task. The encoder must wrap the digest using CIDv1 (version 1), raw codec (0x55), BLAKE3-256 multihash code (0x1e), and a 32-byte digest, then produce lowercase base32 multibase output.
- Iroh and Kubo are optional validation tools only; any future validation must prove that it does not persist the input blob.

## Termux notes

Termux is an Android environment, not a conventional GNU/Linux distribution. Folderstamp attempts `pkg install -y b3sum` when the command is missing. Its standard bootstrap normally includes `coreutils` and the `stat` command; install/restore it with `pkg install coreutils` only if it is missing. Folderstamp keeps the optional Iroh and Kubo download offers available in Termux, but requires an explicit `yes`, displays the phone's `uname -m` architecture, and tests the downloaded executable before replacing anything. The upstream assets currently use generic Linux targets, not a dedicated Android/Bionic target, so successful execution is not guaranteed. A failed test leaves the previous executable untouched and keeps the downloaded archive for inspection.

Support for saving snapshots directly to removable SD-card locations on Android/Termux is not implemented yet. See the SD-card task in `to-do.md` for the planned second phase.

The main script uses `#!/usr/bin/env bash` instead of assuming Bash exists at `/bin/bash`. Start the installer from the repository directory so it can copy the local `folderstamp` script.

## Troubleshooting

- `stat: command not found`: Termux normally includes it; restore it with `pkg install coreutils`.
- `readlink: command not found`: install the platform's `readlink` utility to display symbolic-link targets.
- `sync` or `wc` missing: install the platform's core utilities before using resumable `save`.
- A `.incomplete` file remains: resume it from the original source directory with `folderstamp resume PATH`.
- Recursive mode cannot start: install `find` (Termux package: `findutils`).
- No BLAKE3 digest is shown: Folderstamp attempts to install `b3sum` with `apt` (Debian/Ubuntu) or `pkg` (Termux). You can also install it manually with `apt install b3sum` or `pkg install b3sum`.
- Installer refuses to migrate a legacy stamp: inspect the path manually. It may be a symlink or special file, and Folderstamp intentionally will not move it automatically.
