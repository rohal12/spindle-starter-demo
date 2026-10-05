# Minimal assertion helpers for bash tests. Source this file.
failures=0
pass() { echo "  ok   $1"; }
fail() { echo "  FAIL $1"; failures=$((failures + 1)); }
assert_file()    { [ -e "$1" ] && pass "exists: $1" || fail "missing: $1"; }
assert_no_file() { [ ! -e "$1" ] && pass "absent: $1" || fail "should not exist: $1"; }
assert_grep()    { grep -rq -- "$1" "$2" && pass "'$1' in $2" || fail "'$1' not found in $2"; }
assert_no_grep() { ! grep -rq -- "$1" "$2" && pass "'$1' not in $2" || fail "'$1' unexpectedly in $2"; }
assert_eq()      { [ "$1" = "$2" ] && pass "$3" || fail "$3: expected '$1', got '$2'"; }
assert_fails()   { local label="$1"; shift; if "$@" >/dev/null 2>&1; then fail "$label (succeeded)"; else pass "$label"; fi; }
finish() { if [ "$failures" -gt 0 ]; then echo "$failures failure(s)"; exit 1; fi; echo "all passed"; }
