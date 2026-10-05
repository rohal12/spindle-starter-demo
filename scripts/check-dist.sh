#!/usr/bin/env bash
# Check that <project>/dist is a complete web build of the demo story.
# Usage: scripts/check-dist.sh <project-dir>
set -uo pipefail
dist="${1:?usage: check-dist.sh <project-dir>}/dist"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$root/tests/lib.sh"

html="$dist/index.html"
assert_file "$html"
# Story compiled with the overlay's passages
assert_grep "Spindle Demo" "$html"
for passage in Start Library Dice About StoryVariables StoryInterface; do
  assert_grep "name=\"$passage\"" "$html"
done
# Script and styles were bundled and inlined
assert_grep "rollDice" "$html"
assert_grep "font-family:\"Lora\"\|font-family: \"Lora\"\|font-family:Lora" "$html"
# The app CSS must load after Spindle's own styles, or its rules lose to the
# format's (e.g. body font-family). Story stylesheets are applied after them.
assert_no_grep 'id="style-module-app_bundle"' "$html"
if sed -n '/id="twine-user-stylesheet"/,$p' "$html" | sed '1s/.*id="twine-user-stylesheet"//' | grep -q '@font-face'; then
  pass "app CSS is in the story stylesheet"
else
  fail "app CSS is not in the story stylesheet (would load before Spindle's styles)"
fi
# Media copied to dist/media, font emitted to dist/fonts
assert_file "$dist/media/banner.svg"
assert_file "$dist/media/icon.png"
assert_file "$dist/fonts/lora-latin-400-normal.woff2"
# Asset URLs must be relative so the demo works on a Pages subpath and under file://
assert_grep "url(fonts/lora-latin-400-normal.woff2)" "$html"
assert_no_grep "url(/" "$html"
# A web build must not contain packaging output
assert_no_file "$dist/pack"

finish
