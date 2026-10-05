#!/usr/bin/env bash
# check-dist.sh accepts a complete build and rejects each single defect.
set -uo pipefail
cd "$(dirname "$0")/.."
. tests/lib.sh
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# A minimal project whose dist/ satisfies every check
make_good() {
  local p="$1"
  mkdir -p "$p/dist/media" "$p/dist/fonts" "$p/node_modules/@rohal12/spindle"
  touch "$p/dist/media/banner.svg" "$p/dist/media/icon.png" "$p/dist/fonts/lora-latin-400-normal.woff2"
  echo '{ "name": "@rohal12/spindle", "version": "0.51.3" }' > "$p/node_modules/@rohal12/spindle/package.json"
  cat > "$p/dist/index.html" <<'HTML'
<title>Spindle Demo</title>
<script>window.demo = { rollDice }</script>
<style role="stylesheet" id="twine-user-stylesheet" type="text/twine-css">/* twine-user-stylesheet #1: "app.bundle.css" */
@font-face{font-family:Lora;src:url(fonts/lora-latin-400-normal.woff2)}body{font-family:Lora}
/* twine-user-stylesheet #2: "DemoTheme" */</style>
<tw-storydata name="Spindle Demo" format="spindle" format-version="0.51.3">
<tw-passagedata name="Start"></tw-passagedata><tw-passagedata name="Library"></tw-passagedata>
<tw-passagedata name="Dice"></tw-passagedata><tw-passagedata name="About"></tw-passagedata>
<tw-passagedata name="StoryVariables"></tw-passagedata><tw-passagedata name="StoryInterface"></tw-passagedata>
</tw-storydata>
HTML
}
# mutate NAME SED-EXPR: a good project with one edit to index.html
mutate() { make_good "$tmp/$1"; sed -i "$2" "$tmp/$1/dist/index.html"; }

make_good "$tmp/good"
if scripts/check-dist.sh "$tmp/good" >/dev/null; then pass "accepts a complete build"; else fail "rejects a complete build"; scripts/check-dist.sh "$tmp/good" | grep FAIL; fi

mkdir -p "$tmp/empty/dist"
assert_fails "rejects empty dist" scripts/check-dist.sh "$tmp/empty"

mutate abs 's#url(fonts/#url(/fonts/#'
assert_fails "rejects absolute asset URLs" scripts/check-dist.sh "$tmp/abs"

mutate module 's#<script>#<style id="style-module-app_bundle"></style><script>#'
assert_fails "rejects CSS injected as a head module" scripts/check-dist.sh "$tmp/module"

mutate order 's/#1: "app.bundle.css"/#1: "DemoTheme"/; s/#2: "DemoTheme"/#2: "app.bundle.css"/'
assert_fails "rejects bundle after stylesheet passages" scripts/check-dist.sh "$tmp/order"

mutate format 's/format-version="0.51.3"/format-version="0.51.0"/'
assert_fails "rejects story built with a different Spindle version" scripts/check-dist.sh "$tmp/format"

make_good "$tmp/nofont" && rm "$tmp/nofont/dist/fonts/lora-latin-400-normal.woff2"
assert_fails "rejects missing font" scripts/check-dist.sh "$tmp/nofont"

make_good "$tmp/pack" && mkdir "$tmp/pack/dist/pack"
assert_fails "rejects pack output in a web build" scripts/check-dist.sh "$tmp/pack"

finish
