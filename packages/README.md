# Package manifests

This directory tracks the packages you want on every machine.

## Files

- `arch.txt`: all Arch packages (official + AUR), installed with `yay`
- `brew.txt`: optional Linuxbrew/macOS package list mirror

## Install

```bash
./scripts/install-packages.sh --dry-run
./scripts/install-packages.sh
```
