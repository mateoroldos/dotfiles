#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
checkout="$script_dir/checkout.sh"

usage() {
  cat <<'EOF'
Usage: search.sh <repo> <query> [rg options...]

Example:
  search.sh vercel/next.js "defineConfig" -g '*.ts'
EOF
}

if [[ "$#" -lt 2 ]]; then
  usage >&2
  exit 1
fi

ref="$1"
query="$2"
shift 2

path="$($checkout "$ref" --path-only)"
rg --hidden --glob '!/.git' --line-number --column "$query" "$path" "$@"
