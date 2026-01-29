#!/usr/bin/env bash
set -euo pipefail
set -x

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DIR="$ROOT_DIR/exampleSite/themes/hugo-theme-cleanwhite"

if [[ -L "$THEME_DIR" ]]; then
  rm -f "$THEME_DIR"
fi

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

# Compatibility for older Hugo versions
copy_dir "$ROOT_DIR/layouts/_partials" "$THEME_DIR/layouts/partials"
copy_dir "$ROOT_DIR/layouts/_shortcodes" "$THEME_DIR/layouts/shortcodes"

if [[ -f "$ROOT_DIR/theme.toml" ]]; then
  cp -a "$ROOT_DIR/theme.toml" "$THEME_DIR/"
fi

hugo version
BASEURL=""
if [[ -n "${VERCEL_URL:-}" ]]; then
  BASEURL="https://${VERCEL_URL}"
fi

if [[ -n "$BASEURL" ]]; then
  HUGO_DEST="$ROOT_DIR/exampleSite/public"
  hugo --source "$ROOT_DIR/exampleSite" --destination "$HUGO_DEST" --baseURL "$BASEURL"
else
    HUGO_DEST="$ROOT_DIR/exampleSite/public"
    hugo --source "$ROOT_DIR/exampleSite" --destination "$HUGO_DEST"
fi

  OUTPUT_DIR="${VERCEL_OUTPUT_DIR:-/vercel/output}"
  mkdir -p "$OUTPUT_DIR/static"
  cp -a "$HUGO_DEST/." "$OUTPUT_DIR/static/"

  cat > "$OUTPUT_DIR/config.json" <<'EOF'
  {
    "version": 3,
    "routes": [
      { "handle": "filesystem" }
    ]
  }
  EOF
