#!/usr/bin/env bash
# check-dist.sh must reject an incomplete build.
set -uo pipefail
cd "$(dirname "$0")/.."
. tests/lib.sh
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/empty/dist"
assert_fails "rejects empty dist" scripts/check-dist.sh "$tmp/empty"

mkdir -p "$tmp/abs/dist/media" "$tmp/abs/dist/fonts"
printf '<title>Spindle Demo</title>rollDice url(/fonts/lora-latin-400-normal.woff2)' > "$tmp/abs/dist/index.html"
assert_fails "rejects absolute asset URLs" scripts/check-dist.sh "$tmp/abs"

finish
