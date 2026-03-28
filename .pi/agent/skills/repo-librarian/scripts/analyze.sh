#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"
checkout="$script_dir/checkout.sh"

usage() {
  cat <<'EOF'
Usage: analyze.sh <repo>

Creates or refreshes a reusable markdown note for a cached repo.
EOF
}

if [[ "$#" -ne 1 ]]; then
  usage >&2
  exit 1
fi

ref="$1"
path="$($checkout "$ref" --path-only)"
parsed="$(resolve_repo "$ref")"
IFS=$'\t' read -r host org repo resolved_path <<< "$parsed"
id="$(repo_id "$host" "$org" "$repo")"
note="$(note_path "$host" "$org" "$repo")"
mkdir -p "$(dirname "$note")"

readme="$(find "$path" -maxdepth 1 -iname 'readme*' -type f | head -n 1 || true)"
manifest="$(find "$path" -maxdepth 2 \( -name 'package.json' -o -name 'Cargo.toml' -o -name 'pyproject.toml' -o -name 'go.mod' -o -name 'deno.json' -o -name 'bun.lockb' -o -name 'pnpm-lock.yaml' \) -type f | sed "s#^$path/##" | sort | head -40)"
tree="$(find "$path" -maxdepth 2 -mindepth 1 -not -path '*/.git/*' | sed "s#^$path/##" | sort | head -120)"

{
  printf '# %s\n\n' "$id"
  printf '- Path: `%s`\n' "$path"
  printf '- Updated: `%s`\n\n' "$(date -Iseconds)"

  printf '## Overview\n\n'
  if [[ -n "$readme" ]]; then
    sed -n '1,80p' "$readme"
  else
    printf '_No README found at repository root._\n'
  fi
  printf '\n\n'

  printf '## Manifests and config signals\n\n'
  if [[ -n "$manifest" ]]; then
    printf '```txt\n%s\n```\n\n' "$manifest"
  else
    printf '_No common manifests found in top two levels._\n\n'
  fi

  printf '## Top-level structure\n\n'
  printf '```txt\n%s\n```\n\n' "$tree"

  printf '## Patterns to investigate\n\n'
  printf '- [ ] Architecture boundaries\n'
  printf '- [ ] CLI or app entrypoints\n'
  printf '- [ ] Configuration loading\n'
  printf '- [ ] Error handling\n'
  printf '- [ ] Testing strategy\n'
  printf '- [ ] Examples and documentation structure\n\n'

  printf '## Durable notes\n\n'
  printf '<!-- Add reusable findings here. Cite files as `%s/path/to/file`. -->\n' "$id"
} > "$note"

printf '%s\n' "$note"
