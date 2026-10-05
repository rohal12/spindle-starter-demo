#!/usr/bin/env bash
# Decide what a workflow run builds and publishes. Prints key=value lines for
# $GITHUB_OUTPUT. Inputs come from the environment:
#   EVENT          github.event_name
#   ACTION         github.event.action (repository_dispatch type)
#   PAYLOAD_REF    github.event.client_payload.ref
#   INPUT_REF      workflow_dispatch input `ref`
#   INPUT_VERSION  workflow_dispatch input `version` (optional semver override)
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ref="${PAYLOAD_REF:-${INPUT_REF:-main}}"
"$root/scripts/check-ref.sh" "$ref"

if [ -n "${INPUT_VERSION:-}" ]; then
  version="$("$root/scripts/demo-version.sh" "$INPUT_VERSION")"
  if [ "$version" = "0.0.0" ] && [ "$INPUT_VERSION" != "0.0.0" ]; then
    echo "error: invalid version '$INPUT_VERSION' (expected semver like 2.3.0 or 2.3.0-beta.1)" >&2
    exit 1
  fi
else
  version="$("$root/scripts/demo-version.sh" "$ref")"
fi

# Pages always shows starter main; releases only attach downloads, so an
# older tag (re-run, backport) can never replace a newer site.
deploy=false
release=false
case "${EVENT:-}/${ACTION:-}" in
  repository_dispatch/starter-main | push/*) deploy=true ;;
  repository_dispatch/starter-release) release=true ;;
esac

prerelease=false
[[ "$version" == *-* ]] && prerelease=true

echo "ref=$ref"
echo "version=$version"
echo "deploy=$deploy"
echo "release=$release"
echo "prerelease=$prerelease"
