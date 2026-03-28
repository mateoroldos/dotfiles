#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
PACKAGES_DIR="$ROOT_DIR/packages"

DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: ./scripts/install-packages.sh [--dry-run]

Installs package manifests from packages/:
  - arch.txt
EOF
}

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  "$@"
}

read_package_file() {
  local file_path="$1"
  [[ -f "$file_path" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [[ -z "$line" ]] && continue
    printf '%s\n' "$line"
  done <"$file_path"
}

install_packages() {
  local file_path="$1"
  mapfile -t packages < <(read_package_file "$file_path")
  ((${#packages[@]} == 0)) && return 0

  printf 'Installing packages from %s (%s)\n' "$file_path" "${#packages[@]}"
  run yay -S --needed --noconfirm "${packages[@]}"
}

for arg in "$@"; do
  case "$arg" in
  --dry-run)
    DRY_RUN=true
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    printf 'Unknown argument: %s\n\n' "$arg" >&2
    usage >&2
    exit 1
    ;;
  esac
done

if ! command -v yay >/dev/null 2>&1; then
  echo 'yay not found; install yay before running this script.' >&2
  exit 1
fi

install_packages "$PACKAGES_DIR/arch.txt"

echo 'Package installation complete.'
