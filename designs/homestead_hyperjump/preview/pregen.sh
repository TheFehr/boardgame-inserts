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
# box-only STLs (no lid beside it) for the assembled 3D views
mkdir -p "$OUT/box"
for t in $TRAYS; do
  echo "== box $t"
  /snap/bin/openscad-nightly -D "tray=\"$t\"" -D '$g_print_types="box"' --export-format=binstl -o "$OUT/box/$t.stl" homestead_hyperjump.scad 2>&1 | grep -E 'ERROR' || true
done
# UNTESTED labelled variant (engraved lid and well labels)
mkdir -p "$OUT/../pregen_labels/box"
for t in $TRAYS; do
  echo "== labels $t"
  /snap/bin/openscad-nightly -D "tray=\"$t\"" -D labels=true --export-format=binstl -o "$OUT/../pregen_labels/$t.stl" homestead_hyperjump.scad 2>&1 | grep -E 'ERROR' || true
  /snap/bin/openscad-nightly -D "tray=\"$t\"" -D labels=true -D '$g_print_types="box"' --export-format=binstl -o "$OUT/../pregen_labels/box/$t.stl" homestead_hyperjump.scad 2>&1 | grep -E 'ERROR' || true
done
echo "$TRAYS" | tr ' ' '\n' > "$OUT/trays.txt"
