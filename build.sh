#!/bin/bash
set -e

if [ ! -d ardour ]; then
    git clone git://git.ardour.org/ardour/ardour.git
    cd ardour
    git checkout 8.4
    CFLAGS="-g2 -O0" ./waf configure --strict --libjack=weak --ptformat --cxx11 --no-phone-home --with-backends=alsa,dummy
else
    cd ardour
fi

./waf
