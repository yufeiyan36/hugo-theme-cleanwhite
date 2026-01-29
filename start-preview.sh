#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$ROOT_DIR/exampleSite"
THEMES_DIR="$EXAMPLE_DIR/themes"
THEME_LINK="$THEMES_DIR/hugo-theme-cleanwhite"

mkdir -p "$THEMES_DIR"

if [[ ! -e "$THEME_LINK" ]]; then
  ln -s "$ROOT_DIR" "$THEME_LINK"
fi

hugo server -D --bind 0.0.0.0 --baseURL "http://localhost:1313/" --source "$EXAMPLE_DIR"
