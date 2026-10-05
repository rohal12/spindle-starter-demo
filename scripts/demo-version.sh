#!/usr/bin/env bash
# Print the semver version for a starter ref: release tags (v1.2.3, 1.2.3,
# v1.2.3-beta.1) map to their version, anything else to 0.0.0.
# Usage: scripts/demo-version.sh <ref>
set -euo pipefail
ref="${1:-}"
if [[ "$ref" =~ ^v?([0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?)$ ]]; then
  echo "${BASH_REMATCH[1]}"
else
  echo "0.0.0"
fi
