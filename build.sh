#!/bin/bash
set -e

# IntelliSense
if [ ! -d include ]; then
    cp -r /usr/include .
    cp /usr/lib/x86_64-linux-gnu/*/include/*.h ./include/
fi

if [ ! -d ardour ]; then
    git clone git://git.ardour.org/ardour/ardour.git
    cd ardour
    git checkout 8.4
    CFLAGS="-g2 -O0" ./waf configure --strict --libjack=weak --ptformat --cxx11 --no-phone-home --with-backends=alsa,dummy
else
    cd ardour
fi

./waf
