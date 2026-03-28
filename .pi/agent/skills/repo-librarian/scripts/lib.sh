#!/usr/bin/env bash
set -euo pipefail

cache_root="${REPO_LIBRARIAN_CHECKOUT_ROOT:-$HOME/.cache/checkouts}"
state_root="${REPO_LIBRARIAN_STATE_ROOT:-$HOME/.cache/repo-librarian}"
index_file="$state_root/index.tsv"
stale_seconds="${REPO_LIBRARIAN_STALE_SECONDS:-300}"

ensure_state() {
  mkdir -p "$state_root" "$(dirname "$index_file")"
  touch "$index_file"
}

strip_git_suffix() {
  local value="$1"
  printf '%s' "${value%.git}"
}

parse_repo() {
  local ref="$1"
  local clean host org repo path

  clean="$(strip_git_suffix "$ref")"
  clean="${clean#https://}"
  clean="${clean#http://}"
  clean="${clean#ssh://}"

  if [[ "$clean" =~ ^git@([^:]+):(.+)$ ]]; then
    host="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
  elif [[ "$clean" =~ ^([^@]+@)?([^/]+)/(.+/.+)$ ]]; then
    host="${BASH_REMATCH[2]}"
    path="${BASH_REMATCH[3]}"
  elif [[ "$clean" =~ ^([^/]+)/([^/]+)$ ]]; then
    host="github.com"
    path="$clean"
  else
    echo "Could not parse repo reference: $ref" >&2
    return 1
  fi

  org="${path%%/*}"
  repo="${path#*/}"
  repo="${repo%%/*}"

  if [[ -z "$host" || -z "$org" || -z "$repo" ]]; then
    echo "Could not parse repo reference: $ref" >&2
    return 1
  fi

  printf '%s\t%s\t%s\n' "$host" "$org" "$repo"
}

repo_id() {
  local host="$1" org="$2" repo="$3"
  printf '%s/%s/%s' "$host" "$org" "$repo"
}

repo_path() {
  local host="$1" org="$2" repo="$3"
  printf '%s/%s/%s/%s' "$cache_root" "$host" "$org" "$repo"
}

repo_url() {
  local host="$1" org="$2" repo="$3"
  printf 'https://%s/%s/%s.git' "$host" "$org" "$repo"
}

note_path() {
  local host="$1" org="$2" repo="$3"
  printf '%s/notes/%s/%s/%s.md' "$state_root" "$host" "$org" "$repo"
}

now_epoch() {
  date +%s
}

last_fetch_file() {
  local dir="$1"
  printf '%s/.repo-librarian-last-fetch' "$dir"
}

is_stale() {
  local dir="$1" stamp now last age
  stamp="$(last_fetch_file "$dir")"

  [[ ! -f "$stamp" ]] && return 0

  now="$(now_epoch)"
  last="$(cat "$stamp")"
  age=$((now - last))

  [[ "$age" -ge "$stale_seconds" ]]
}

touch_fetch_stamp() {
  local dir="$1"
  now_epoch > "$(last_fetch_file "$dir")"
}

is_clean_git_tree() {
  local dir="$1"
  [[ -z "$(git -C "$dir" status --porcelain)" ]]
}

has_upstream() {
  local dir="$1"
  git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1
}

upsert_index() {
  local host="$1" org="$2" repo="$3" path="$4"
  local id tmp tags
  ensure_state
  id="$(repo_id "$host" "$org" "$repo")"
  tmp="$(mktemp)"
  tags="$(awk -F '\t' -v id="$id" '$1 == id { print $6 }' "$index_file" | tail -n 1)"
  awk -F '\t' -v id="$id" '$1 != id' "$index_file" > "$tmp"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "$host" "$org" "$repo" "$path" "$tags" >> "$tmp"
  mv "$tmp" "$index_file"
}

resolve_repo() {
  local ref="$1" parsed host org repo path
  parsed="$(parse_repo "$ref")"
  IFS=$'\t' read -r host org repo <<< "$parsed"
  path="$(repo_path "$host" "$org" "$repo")"
  printf '%s\t%s\t%s\t%s\n' "$host" "$org" "$repo" "$path"
}
