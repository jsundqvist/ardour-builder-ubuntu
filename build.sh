#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ ! -d ardour ]]; then
    git clone git://git.ardour.org/ardour/ardour.git
    git -C ardour checkout 8.4
fi

cd ardour
CFLAGS="-g2 -O0" ./waf configure --strict --libjack=weak --ptformat --cxx11 --no-phone-home --with-backends=alsa,dummy
./waf
