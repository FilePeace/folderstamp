# Folderstamp

Folderstamp creates a human-readable snapshot of regular files in the current directory. It records filesystem metadata and, when an available provider supports it, a content identifier (CID).

## Requirements

- Bash 4+ (the script is written for Bash, not POSIX sh).
- `stat` for file metadata. The standard Termux bootstrap normally includes `coreutils`, which provides `stat`; if it is missing, install/restore it with `pkg install coreutils`.
- `readlink` to display symbolic-link targets (optional; without it, the link metadata is still shown).
- `sync` and `wc` for durable checkpoint/resume support when using `save`.
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

## Content identifiers and limitations

- Iroh's supported legacy blob CLI computes a BLAKE3 blob digest; Folderstamp wraps it as CIDv1/raw/BLAKE3.
- Python + `blake3` computes the same CIDv1/raw/BLAKE3 profile incrementally.
- Kubo/IPFS is retained as a compatibility provider.
- The Python CIDv0 fallback is explicitly single-block UnixFS/DAG-PB. It is not a full IPFS importer: it does not implement chunking, directory DAGs, or importer layout options.
- A raw BLAKE3 digest or Iroh BlobId is not itself a CID; the script only labels the value as a CID after wrapping it in the CIDv1 structure.

## Termux notes

Termux is an Android environment, not a conventional GNU/Linux distribution. Its standard bootstrap normally includes `coreutils` and the `stat` command; install/restore it with `pkg install coreutils` only if it is missing. Folderstamp keeps the optional Iroh and Kubo download offers available in Termux, but requires an explicit `yes`, displays the phone's `uname -m` architecture, and tests the downloaded executable before replacing anything. The upstream assets currently use generic Linux targets, not a dedicated Android/Bionic target, so successful execution is not guaranteed. A failed test leaves the previous executable untouched and keeps the downloaded archive for inspection.

Support for saving snapshots directly to removable SD-card locations on Android/Termux is not implemented yet. See the SD-card task in `to-do.md` for the planned second phase.

The main script uses `#!/usr/bin/env bash` instead of assuming Bash exists at `/bin/bash`. Start the installer from the repository directory so it can copy the local `folderstamp` script.

## Troubleshooting

- `stat: command not found`: Termux normally includes it; restore it with `pkg install coreutils`.
- `readlink: command not found`: install the platform's `readlink` utility to display symbolic-link targets.
- `sync` or `wc` missing: install the platform's core utilities before using resumable `save`.
- A `.incomplete` file remains: resume it from the original source directory with `folderstamp resume PATH`.
- Recursive mode cannot start: install `find` (Termux package: `findutils`).
- No CID is shown: continue using metadata snapshots, or install one of the optional content-hash providers.
- Installer refuses to migrate a legacy stamp: inspect the path manually. It may be a symlink or special file, and Folderstamp intentionally will not move it automatically.
