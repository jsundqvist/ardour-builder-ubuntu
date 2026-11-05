#!/usr/bin/env bash
set -eo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOP="$ROOT_DIR/ardour"

. "$TOP/build/gtk2_ardour/ardev_common_waf.sh"

exec "$ROOT_DIR/.vscode/ardour-exec-wrapper.sh" "$TOP/$EXECUTABLE" "$@"