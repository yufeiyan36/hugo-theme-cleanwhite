#!/usr/bin/env bash
set -euo pipefail
set -x

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DIR="$ROOT_DIR/exampleSite/themes/hugo-theme-cleanwhite"

mkdir -p "$THEME_DIR"

copy_dir() {
  local src="$1"
  local dest="$2"
  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    cp -a "$src/." "$dest/"
  fi
}

copy_dir "$ROOT_DIR/layouts" "$THEME_DIR/layouts"
copy_dir "$ROOT_DIR/static" "$THEME_DIR/static"
copy_dir "$ROOT_DIR/archetypes" "$THEME_DIR/archetypes"
copy_dir "$ROOT_DIR/assets" "$THEME_DIR/assets"
copy_dir "$ROOT_DIR/data" "$THEME_DIR/data"
copy_dir "$ROOT_DIR/i18n" "$THEME_DIR/i18n"

if [[ -f "$ROOT_DIR/theme.toml" ]]; then
  cp -a "$ROOT_DIR/theme.toml" "$THEME_DIR/"
fi

hugo version
hugo --source "$ROOT_DIR/exampleSite" --destination "$ROOT_DIR/exampleSite/public"
