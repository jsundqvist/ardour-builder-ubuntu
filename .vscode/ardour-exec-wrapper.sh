#!/usr/bin/env bash
set -eo pipefail

WORKSPACE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TOP="$WORKSPACE_DIR/ardour"
PIPEWIRE_JACK_DIR=/usr/lib/x86_64-linux-gnu/pipewire-0.3/jack

if [[ ! -e "$PIPEWIRE_JACK_DIR/libjack.so.0" ]]; then
	printf 'PipeWire JACK library not found: %s\n' "$PIPEWIRE_JACK_DIR/libjack.so.0" >&2
	exit 1
fi

. "$TOP/build/gtk2_ardour/ardev_common_waf.sh"

# Ensure PipeWire runtime paths include the current UID.
if [[ -z "${XDG_RUNTIME_DIR:-}" || "$XDG_RUNTIME_DIR" == "/run/user/" ]]; then
	export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi
export PIPEWIRE_RUNTIME_DIR="${PIPEWIRE_RUNTIME_DIR:-$XDG_RUNTIME_DIR}"
export PULSE_SERVER="${PULSE_SERVER:-unix:${XDG_RUNTIME_DIR}/pulse/native}"

# Force non-ALSA backend selection from this repo launch path.
export ARDOUR_BACKEND_PATH="$libs/backends/jack:$libs/backends/dummy"
export LD_LIBRARY_PATH="$PIPEWIRE_JACK_DIR:$LD_LIBRARY_PATH"
export LD_PRELOAD="$PIPEWIRE_JACK_DIR/libjack.so.0${LD_PRELOAD:+:$LD_PRELOAD}"
export JACK_NO_START_SERVER=1

exec "$@"