#!/usr/bin/env bash
# Exit 0 if <ref> is a plain branch, tag or SHA name; 1 otherwise. Refs come
# from repository_dispatch payloads and workflow inputs, so anything that
# could act as shell, a git option or an extra output line is rejected.
# Usage: scripts/check-ref.sh <ref>
set -euo pipefail
ref="${1:-}"
if [[ "$ref" =~ ^[A-Za-z0-9][A-Za-z0-9._/-]*$ ]]; then
  exit 0
fi
echo "error: invalid ref '$ref' (allowed: letters, digits, . _ / -; must not start with -)" >&2
exit 1
