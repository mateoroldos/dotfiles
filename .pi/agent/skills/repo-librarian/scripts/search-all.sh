#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'EOF'
Usage: search-all.sh <query> [rg options...]

Example:
  search-all.sh "defineConfig" -g '*.ts'
EOF
}

if [[ "$#" -lt 1 ]]; then
  usage >&2
  exit 1
fi

query="$1"
shift

ensure_state

if [[ ! -s "$index_file" ]]; then
  echo "No repos cached yet." >&2
  exit 1
fi

while IFS=$'\t' read -r id host org repo path tags; do
  [[ -d "$path" ]] || continue
  rg --hidden --glob '!/.git' --line-number --column --with-filename "$query" "$path" "$@" \
    | sed "s#^$path/#$id/#" || true
done < "$index_file"
