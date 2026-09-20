# Bash Script Craft Skill

Use this skill when creating or reviewing shell scripts for Perla's projects. The goal is to write Bash that survives real machines, not just a shiny Linux container with every dependency preinstalled like a fake Web3 roadmap.

## Voice and project expectations

- Prefer clear comments where behavior is not obvious.
- Prefer helpful diagnostics over silent failure.
- If a dependency is missing, say exactly what is missing and suggest an install command when the platform is known.
- Keep scripts friendly for debugging: print platform, relevant tool paths, fallback choices, and what the script is about to do.
- Avoid fragile assumptions like `/usr/bin`, `sudo`, GNU-only flags, or a single package manager.

## Portability checklist

Detect the platform before choosing paths or install commands. Consider at least:

- Linux and common package managers: `apt-get`, `dnf`, `pacman`, `apk`, `zypper`.
- Termux/Android: `$TERMUX_VERSION`, `$PREFIX`, `uname -o Android`, install into `$PREFIX/bin`, avoid `sudo`.
- Cygwin: `uname -s` starting with `CYGWIN`, prefer `/usr/local/bin`, mention the Cygwin setup executable for packages.
- BSD: `FreeBSD`, `OpenBSD`, `NetBSD`, `DragonFly`; try `pkg` or `pkg_add` and avoid assuming GNU userland.
- macOS: `Darwin`; prefer Homebrew when available but do not require it.
- RedoxOS: `Redox`; prefer user-writable install paths such as `$HOME/bin` when unsure.
- Zircon/Fuchsia: `Fuchsia` or `Zircon`; report limitations clearly because package workflows vary by image/build.

## Dependency handling

- Wrap command detection in a helper such as `command_exists() { command -v "$1" >/dev/null 2>&1; }`.
- Check critical commands before use (`stat`, `find`, `sed`, `awk`, `df`, `tar`, `curl`, VCS tools). When `stat` is required, prefer restoring/installing the normal platform command through its package manager. Offer a Rust-compatible implementation such as uutils/coreutils separately and never silently replace the system command.
- Prefer graceful fallbacks:
  - `lsblk` for Linux storage details, then `df -hP` as fallback.
  - Git metadata via `git`, with Gitoxide/`gix` as a supported alternative where possible.
  - Pijul metadata when `.pijul` exists and `pijul` is installed.
- Optional tools should not break the main script unless the user explicitly requested that feature. Prefer Iroh/BLAKE3 for new content-addressing work; keep Kubo/IPFS as a compatibility fallback.

## Interactive installers

- If a missing tool can be installed from GitHub Releases, offer an interactive yes/no prompt when stdin is a TTY.
- If stdin is not a TTY, print the install/release URL and continue safely.
- Install into user-writable locations first (`$PREFIX/bin`, `$HOME/.local/bin`) before attempting privileged paths.
- Never require `sudo` on Termux.
- For a system package install, run the detected package-manager command only after an explicit prompt; use `sudo` only when needed and available, and explain the privilege limitation otherwise.
- If auto-install needs helper tools (`curl`, `tar`, `python3`), check them first and explain what is missing.

## Bash style

- Use `#!/bin/bash -e` only when Bash features are actually used; otherwise use POSIX `sh`.
- Quote variables unless intentionally splitting.
- Keep repeated logic in functions.
- Use `while IFS= read -r -d ''` with `find -print0` for filenames that may contain spaces/newlines.
- Avoid `grep -R`; prefer `rg` in repo work and targeted `find` where needed.
- Do not put try/catch-style wrappers around imports in languages that have imports.

## Documentation expectations

- Keep `CHANGELOG.md` updated when behavior changes.
- Keep `to-do.md` organized with checkboxes and theme sections.
- Prefer a `README.md` for scripts with install, usage, examples, troubleshooting, and platform notes.
- When generating an environment stamp, commit `.folderstamp` only if explicitly requested.

## Metadata output convention

- Prefer storing generated metadata under `.meta/<tool-name>/` instead of cluttering the project root.
- When migrating legacy root metadata files, preserve them by numbering old outputs before creating the next stamp.
- Keep durable stamps concise: emit one environment/tooling summary line with command paths or `missing`, not a multi-line dependency-installation transcript. Put prompts and remediation guidance in an explicit diagnostic flow instead.

## CID naming

- Prefer the neutral label `CID hash:` instead of brand-specific labels such as `IPFS hash:`.
- When implementing CID fallbacks, document whether the implementation is basic/single-block or feature-complete. Never label a raw Iroh BLAKE3 BlobId as a CID; construct a CIDv1 explicitly when that is what is emitted.
- When comparing compatible single-file providers, use the same CIDv1/raw codec and BLAKE3 multihash settings; validate the resulting CID against Kubo's `ipfs add --only-hash --cid-version=1 --raw-leaves --hash=blake3`.
