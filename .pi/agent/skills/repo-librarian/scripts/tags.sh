#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"
checkout="$script_dir/checkout.sh"

usage() {
  cat <<'EOF'
Usage:
  tags.sh add <repo> <tag...>
  tags.sh list <repo>
EOF
}

normalize_tags() {
  tr ' ' '\n' | awk 'NF' | sort -u | paste -sd ',' -
}

cmd="${1:-}"
[[ -n "$cmd" ]] || { usage >&2; exit 1; }
shift

case "$cmd" in
  add)
    if [[ "$#" -lt 2 ]]; then usage >&2; exit 1; fi
    ref="$1"
    shift
    path="$($checkout "$ref" --path-only)"
    parsed="$(resolve_repo "$ref")"
    IFS=$'\t' read -r host org repo resolved_path <<< "$parsed"
    id="$(repo_id "$host" "$org" "$repo")"
    ensure_state
    tmp="$(mktemp)"
    existing="$(awk -F '\t' -v id="$id" '$1 == id { print $6 }' "$index_file" | tail -n 1 | tr ',' ' ')"
    tags="$(printf '%s %s\n' "$existing" "$*" | normalize_tags)"
    awk -F '\t' -v id="$id" '$1 != id' "$index_file" > "$tmp"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "$host" "$org" "$repo" "$path" "$tags" >> "$tmp"
    mv "$tmp" "$index_file"
    printf '%s\n' "$tags"
    ;;
  list)
    if [[ "$#" -ne 1 ]]; then usage >&2; exit 1; fi
    parsed="$(resolve_repo "$1")"
    IFS=$'\t' read -r host org repo path <<< "$parsed"
    id="$(repo_id "$host" "$org" "$repo")"
    ensure_state
    awk -F '\t' -v id="$id" '$1 == id { print $6 }' "$index_file" | tail -n 1 | tr ',' '\n'
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
