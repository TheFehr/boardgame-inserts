#!/usr/bin/env bash
# Re-render every tray to preview/site/pregen/<tray>.stl with native
# openscad-nightly (snap: output must be under $HOME). Run after editing
# homestead_hyperjump.scad.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
OUT=preview/site/pregen; mkdir -p "$OUT"
TRAYS="chance_green chance_yellow chance_red sector_green sector_yellow sector_red hex_green hex_yellow hex_red characters misc_top misc_tokens cards_small ship"
for t in $TRAYS; do
  echo "== $t"
  /snap/bin/openscad-nightly -D "tray=\"$t\"" --export-format=binstl -o "$OUT/$t.stl" homestead_hyperjump.scad 2>&1 | grep -E 'ERROR' || true
done
echo "$TRAYS" | tr ' ' '\n' > "$OUT/trays.txt"
