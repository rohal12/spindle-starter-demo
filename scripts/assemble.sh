#!/usr/bin/env bash
# Assemble a buildable demo project: spindle-starter at <ref> (without .git,
# like `npx degit`) with this repo's overlay/ copied on top.
#
# Usage: scripts/assemble.sh <ref> <dir>
#   <ref>  spindle-starter branch, tag or commit SHA
#   <dir>  output directory (must be empty or not exist)
set -euo pipefail

ref="${1:?usage: assemble.sh <ref> <dir>}"
dir="${2:?usage: assemble.sh <ref> <dir>}"
repo="${STARTER_REPO:-https://github.com/rohal12/spindle-starter.git}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -e "$dir" ] && [ -n "$(ls -A "$dir")" ]; then
  echo "error: $dir is not empty" >&2
  exit 1
fi
mkdir -p "$dir"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# fetch (rather than clone --branch) also accepts commit SHAs
git -C "$tmp" init -q
git -C "$tmp" remote add origin "$repo"
if ! git -C "$tmp" fetch -q --depth 1 origin "$ref"; then
  echo "error: could not fetch '$ref' from $repo" >&2
  exit 1
fi
git -C "$tmp" archive FETCH_HEAD | tar -x -C "$dir"

# The demo story replaces the starter's hello-world passages entirely
rm -rf "$dir/src/story"
cp -R "$root/overlay/." "$dir/"

echo "Assembled spindle-starter@$ref + overlay in $dir"
