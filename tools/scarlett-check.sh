#!/usr/bin/env bash
# Preflight/diagnostic for the Scarlett 18i20 as seen from inside the container.
# Exit 0 = looks usable, 1 = problem found. Safe to run while Ardour is closed.
set -uo pipefail

NAME=${SCARLETT_NAME:-Scarlett 18i20}
bad=0
fail() { printf 'FAIL: %s\n' "$*" >&2; bad=1; }
info() { printf 'ok:   %s\n' "$*"; }

# The card can take a few seconds to enumerate after a power cycle or replug.
for _ in {1..10}; do
  CARD=$(aplay -l 2>/dev/null | sed -n "s/^card \([0-9]*\): .*$NAME.*/\1/p" | head -n1)
  [[ -n "$CARD" ]] && break
  sleep 1
done
if [[ -z "$CARD" ]]; then
  fail "$NAME not visible in the container. /dev/snd is a snapshot taken at container start; power the interface on, then reopen/rebuild the container (or restart it)."
  exit 1
fi
info "$NAME is ALSA card $CARD (card number changes between boots; Ardour matches by name)"

for node in controlC$CARD pcmC${CARD}D0p pcmC${CARD}D0c; do
  [[ -r /dev/snd/$node && -w /dev/snd/$node ]] || fail "no rw access to /dev/snd/$node (user not in audio group / stale ACL)"
done

if err=$(timeout 3 aplay -D "hw:$CARD" -f S32_LE -c 20 -r 48000 -d 1 /dev/zero 2>&1 >/dev/null); then
  info "hw:$CARD opens at 20ch/48k"
else
  if pgrep -x ArdourGUI >/dev/null; then
    info "hw:$CARD is held by a running Ardour (skipping open test)"
  else
    fail "cannot open hw:$CARD: ${err##*$'\n'} (busy = another client, e.g. host PipeWire, holds it)"
  fi
fi

get() { amixer -c "$CARD" cget "name='$1'" 2>/dev/null | sed -n 's/.*: values=//p' | head -n1; }

[[ $(get 'Sync Status') == 1 ]] && info "clock locked" || fail "Sync Status unlocked"
[[ $(get 'Clock Source Clock Source') == 0 ]] && info "clock source Internal" || fail "clock source is not Internal"
[[ $(get 'Mute Playback Switch') == off ]] || fail "global Mute is on"
[[ $(get 'Dim Playback Switch') == off ]] || fail "Dim is on"

for n in {01..10}; do
  [[ $(get "Line $n Mute Playback Switch") == off ]] || fail "Line $n is muted"
done

routes=$(for n in {01..10}; do
  v=$(get "Analogue Output $n Playback Enum")
  item=$(amixer -c "$CARD" cget "name='Analogue Output $n Playback Enum'" | grep -oE "Item #$v '[^']*'" | sed "s/Item #$v //")
  printf 'Out%s<-%s ' "${n#0}" "${item//\'/}"
done)
info "hardware output routing: $routes"

exit $bad
