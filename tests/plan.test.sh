#!/usr/bin/env bash
# plan.sh turns the triggering event into build settings.
set -uo pipefail
cd "$(dirname "$0")/.."
. tests/lib.sh

# run_plan EVENT ACTION PAYLOAD_REF INPUT_REF INPUT_VERSION -> prints plan.sh output
run_plan() { EVENT="$1" ACTION="$2" PAYLOAD_REF="$3" INPUT_REF="$4" INPUT_VERSION="$5" scripts/plan.sh 2>/dev/null; }
# expect LABEL "OUTPUT" key=value...
expect() {
  local label="$1" out="$2"; shift 2
  for kv in "$@"; do
    if grep -qx -- "$kv" <<<"$out"; then pass "$label: $kv"; else fail "$label: expected $kv in: $(tr '\n' ' ' <<<"$out")"; fi
  done
}

expect "push to demo main" "$(run_plan push '' '' '' '')" \
  ref=main deploy=true release=false prerelease=false version=0.0.0
expect "starter main push" "$(run_plan repository_dispatch starter-main 07a2a525669454088a51784e6ed4f56dd018a375 '' '')" \
  ref=07a2a525669454088a51784e6ed4f56dd018a375 deploy=true release=false version=0.0.0
expect "starter-main without ref" "$(run_plan repository_dispatch starter-main '' '' '')" \
  ref=main deploy=true
# Releases attach downloads but don't deploy: Pages always shows starter main,
# so an older tag can never replace a newer site
expect "starter release" "$(run_plan repository_dispatch starter-release v2.3.0 '' '')" \
  ref=v2.3.0 deploy=false release=true prerelease=false version=2.3.0
expect "starter prerelease" "$(run_plan repository_dispatch starter-release v2.3.0-beta.1 '' '')" \
  release=true prerelease=true version=2.3.0-beta.1
expect "manual run" "$(run_plan workflow_dispatch '' '' demo-project '')" \
  ref=demo-project deploy=false release=false version=0.0.0
expect "manual run with version" "$(run_plan workflow_dispatch '' '' main 2.3.0-beta.1)" \
  ref=main version=2.3.0-beta.1 release=false

assert_fails "rejects invalid ref" run_plan repository_dispatch starter-main 'x"; id; "' '' ''
assert_fails "rejects invalid version" run_plan workflow_dispatch '' '' main 'banana'

finish
