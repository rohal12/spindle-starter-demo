#!/usr/bin/env bash
# Integration test: needs network access to github.com.
set -uo pipefail
cd "$(dirname "$0")/.."
. tests/lib.sh

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
sha="$(git ls-remote https://github.com/rohal12/spindle-starter.git refs/heads/main | cut -f1)"

for ref in main v2.2.0 "$sha"; do
  echo "ref: $ref"
  dir="$tmp/$ref"
  if scripts/assemble.sh "$ref" "$dir" >/dev/null; then pass "assemble $ref"; else fail "assemble $ref"; continue; fi
  assert_file "$dir/package.json"
  assert_file "$dir/vite.config.ts"
  assert_no_file "$dir/.git"
  # Overlay replaced the starter story: title comes from the overlay, and nothing
  # from the starter's story survives (its text and its IFID are gone)
  assert_grep "Spindle Demo" "$dir/src/story/Start.twee"
  assert_no_grep "Hello World" "$dir/src/story"
  assert_no_grep "D674C58C-DEFA-4F70-B7A2-27742230C0FC" "$dir/src/story"
done

echo "errors"
mkdir -p "$tmp/nonempty" && touch "$tmp/nonempty/x"
assert_fails "rejects non-empty dir" scripts/assemble.sh main "$tmp/nonempty"
assert_fails "rejects unknown ref" scripts/assemble.sh no-such-ref-xyz "$tmp/bad"
assert_fails "requires args" scripts/assemble.sh

finish
