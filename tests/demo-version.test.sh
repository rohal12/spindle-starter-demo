#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/.."
. tests/lib.sh

check() { assert_eq "$2" "$(scripts/demo-version.sh "$1" 2>/dev/null)" "demo-version $1"; }
check v2.2.0 2.2.0
check 2.3.0 2.3.0
check v2.3.0-beta.1 2.3.0-beta.1
check v10.20.30 10.20.30
check main 0.0.0
check 3192943a1b2c3d4e5f60718293a4b5c6d7e8f901 0.0.0
check v2.2 0.0.0
check "v2.2.0; rm -rf /" 0.0.0
check "" 0.0.0

finish
