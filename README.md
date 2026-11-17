# Folderstamp

Folderstamp creates a human-readable snapshot of regular files in the current directory. It records filesystem metadata and, when an available provider supports it, a content identifier (CID).

## Requirements

- Bash 4+ (the script is written for Bash, not POSIX sh).
- `stat` for file metadata.
- `find` for recursive mode.
- `df` and `awk` are optional and used for storage diagnostics.
- A content-hash provider is optional:
  - Iroh CLI (preferred when the supported legacy blob CLI is installed).
  - Python 3 + the `blake3` module.
  - Kubo/IPFS as a compatibility fallback.
  - Python 3 alone provides a basic single-block CIDv0 fallback.

Folderstamp does not require Git, Gitoxide, Pijul, Iroh, Python, or Kubo merely to list file metadata. Missing optional tools should not prevent a normal metadata snapshot.

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
folderstamp --help
```

- `display` writes the snapshot to standard output.
- `save` stores a completed snapshot under `.meta/folderstamp/`.
- Existing snapshots are rotated to the next available name and are not intentionally overwritten.

## Included and excluded paths

- Regular files are included.
- Hidden files are included in both recursive and non-recursive modes.
- Symbolic links are skipped. This avoids following links outside the selected tree or recording ambiguous link targets.
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

These measures reduce accidental clobbering and partial snapshots. They are not a substitute for backups, and simultaneous writers on unusual network filesystems may still have filesystem-specific semantics.

## Content identifiers and limitations

- Iroh's supported legacy blob CLI computes a BLAKE3 blob digest; Folderstamp wraps it as CIDv1/raw/BLAKE3.
- Python + `blake3` computes the same CIDv1/raw/BLAKE3 profile incrementally.
- Kubo/IPFS is retained as a compatibility provider.
- The Python CIDv0 fallback is explicitly single-block UnixFS/DAG-PB. It is not a full IPFS importer: it does not implement chunking, directory DAGs, or importer layout options.
- A raw BLAKE3 digest or Iroh BlobId is not itself a CID; the script only labels the value as a CID after wrapping it in the CIDv1 structure.

## Termux notes

Termux is an Android environment, not a conventional GNU/Linux distribution. Linux release binaries may target glibc or musl and are not automatically compatible with Android's Bionic environment. For that reason, prefer Termux packages or a native Termux build for optional tools; do not assume that an asset named `linux-arm64` will run on Android.

The main script uses `#!/usr/bin/env bash` instead of assuming Bash exists at `/bin/bash`. Start the installer from the repository directory so it can copy the local `folderstamp` script.

## Troubleshooting

- `stat: command not found`: install Termux `coreutils` or the equivalent package for your platform.
- Recursive mode cannot start: install `find` (Termux package: `findutils`).
- No CID is shown: continue using metadata snapshots, or install one of the optional content-hash providers.
- Installer refuses to migrate a legacy stamp: inspect the path manually. It may be a symlink or special file, and Folderstamp intentionally will not move it automatically.
