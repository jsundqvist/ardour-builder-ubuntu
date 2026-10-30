#!/usr/bin/env bash
set -eo pipefail

WORKSPACE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TOP="$WORKSPACE_DIR/ardour"
PIPEWIRE_JACK_DIR=/usr/lib/x86_64-linux-gnu/pipewire-0.3/jack

. "$TOP/build/gtk2_ardour/ardev_common_waf.sh"
export LD_LIBRARY_PATH="$PIPEWIRE_JACK_DIR:$LD_LIBRARY_PATH"
export LD_PRELOAD="$PIPEWIRE_JACK_DIR/libjack.so.0${LD_PRELOAD:+:$LD_PRELOAD}"
export JACK_NO_START_SERVER=1

exec "$@"