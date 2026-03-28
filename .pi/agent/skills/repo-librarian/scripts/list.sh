#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

ensure_state

if [[ ! -s "$index_file" ]]; then
  echo "No repos cached yet."
  exit 0
fi

awk -F '\t' '{ printf "%s\t%s", $1, $5; if ($6 != "") printf "\t%s", $6; printf "\n" }' "$index_file" | sort
