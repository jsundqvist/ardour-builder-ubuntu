#!/usr/bin/env bash
set -eo pipefail

WORKSPACE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TOP="$WORKSPACE_DIR/ardour"

. "$TOP/build/gtk2_ardour/ardev_common_waf.sh"

# Warn-only; set ARDOUR_ALSA_PREFLIGHT=0 where Ardour runs on JACK/PipeWire instead of ALSA.
if [[ "${ARDOUR_ALSA_PREFLIGHT:-1}" != 0 ]]; then
	"$WORKSPACE_DIR/tools/scarlett-check.sh" || echo "Scarlett preflight failed; Ardour may start silent or on the wrong device." >&2
fi

exec "$@"