#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ ! -d ardour ]]; then
    git clone https://git.ardour.org/ardour/ardour.git
    git -C ardour checkout 8.12
fi

cd ardour
./waf configure --strict --optimize --libjack=weak --ptformat --cxx11 --no-phone-home --with-backends=alsa,jack,pulseaudio
./waf