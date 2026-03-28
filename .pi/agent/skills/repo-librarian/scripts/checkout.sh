#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'EOF'
Usage: checkout.sh <repo> [--path-only] [--force-update]

Examples:
  checkout.sh vercel/next.js --path-only
  checkout.sh https://github.com/vercel/next.js --force-update
EOF
}

ref=""
path_only=0
force_update=0

for arg in "$@"; do
  case "$arg" in
    --path-only) path_only=1 ;;
    --force-update) force_update=1 ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [[ -n "$ref" ]]; then
        echo "Unexpected argument: $arg" >&2
        usage >&2
        exit 1
      fi
      ref="$arg"
      ;;
  esac
done

if [[ -z "$ref" ]]; then
  usage >&2
  exit 1
fi

parsed="$(resolve_repo "$ref")"
IFS=$'\t' read -r host org repo path <<< "$parsed"
url="$(repo_url "$host" "$org" "$repo")"

mkdir -p "$(dirname "$path")"

if [[ ! -d "$path/.git" ]]; then
  [[ "$path_only" -eq 0 ]] && echo "Cloning $url -> $path" >&2
  git clone --filter=blob:none "$url" "$path"
  touch_fetch_stamp "$path"
elif [[ "$force_update" -eq 1 || "$(is_stale "$path" && echo yes || echo no)" == "yes" ]]; then
  [[ "$path_only" -eq 0 ]] && echo "Fetching $url" >&2
  git -C "$path" fetch --prune origin
  touch_fetch_stamp "$path"

  if is_clean_git_tree "$path" && has_upstream "$path"; then
    git -C "$path" merge --ff-only '@{u}' >/dev/null || true
  elif [[ "$path_only" -eq 0 ]]; then
    echo "Skipping fast-forward: checkout is dirty or has no upstream" >&2
  fi
fi

upsert_index "$host" "$org" "$repo" "$path"

if [[ "$path_only" -eq 1 ]]; then
  printf '%s\n' "$path"
else
  printf '%s\t%s\n' "$(repo_id "$host" "$org" "$repo")" "$path"
fi
