#!/usr/bin/env bash
set -euo pipefail

# Map four Ardour audio tracks directly to Scarlett hardware outputs 3-6.
# This script intentionally ignores any TD-27 or passthrough routing.

APPLY=0
START_AUX=${ARDOUR_TRACK_MAP_START_AUX:-2} # AUX2..AUX5 => playback 3..6

usage() {
  cat <<'EOF'
Usage: scarlett-analog-3to10.sh [--apply]

Options:
  --apply      Execute changes. Without this flag, show dry-run only.
  -h, --help   Show this help.

Environment:
  ARDOUR_TRACK_MAP_START_AUX  First AUX index for 4-track mapping (default 2)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1 ;;
    -h|--help) usage; exit 0 ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

if ! command -v pw-link >/dev/null 2>&1; then
  echo "pw-link is required but not found." >&2
  exit 1
fi

SCARLETT_PREFIX=$(pw-link -i | sed -n 's/^\(.*\):playback_AUX0$/\1/p' | head -n1)
if [[ -z "$SCARLETT_PREFIX" ]]; then
  echo "Could not find Scarlett playback_AUX ports." >&2
  exit 1
fi

run() {
  if [[ $APPLY -eq 1 ]]; then
    if [[ "${1:-}" == "pw-link" && "${2:-}" == "-d" ]]; then
      "$@" >/dev/null 2>&1 || true
    elif [[ "${1:-}" == "pw-link" ]]; then
      local err
      if ! err=$("$@" 2>&1); then
        if [[ "$err" == *"File exists"* ]]; then
          true
        else
          printf '%s\n' "$err" >&2
          return 1
        fi
      fi
    else
      "$@"
    fi
  else
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
  fi
}

mapfile -t OUT1_PORTS < <(
  pw-link -o | awk '
    /^ardour:.*\/audio_out 1$/ {
      if ($0 ~ /^ardour:Master\/audio_out 1$/) next
      if ($0 ~ /^ardour:Click\/audio_out 1$/) next
      if ($0 ~ /^ardour:auditioner\/audio_out 1$/) next
      print
    }
  ' | head -n 4
)

if [[ ${#OUT1_PORTS[@]} -eq 0 ]]; then
  echo "No Ardour track outputs found (excluding Master/Click/Auditioner)."
  exit 0
fi

echo "Applying 1:1 track map to Scarlett playback outputs starting at AUX${START_AUX}"

# Remove legacy broad routing from prior debugging runs.
for src in \
  'ardour:Master/audio_out 1' \
  'ardour:Master/audio_out 2' \
  'ardour:Click/audio_out 1' \
  'ardour:Click/audio_out 2' \
  'ardour:auditioner/audio_out 1' \
  'ardour:auditioner/audio_out 2'
do
  for aux in {0..19}; do
    run pw-link -d "$src" "$SCARLETT_PREFIX:playback_AUX$aux"
  done
done

for i in "${!OUT1_PORTS[@]}"; do
  out1="${OUT1_PORTS[$i]}"
  base="${out1%/audio_out 1}"
  out2="$base/audio_out 2"
  dest_aux=$((START_AUX + i))

  # Clear existing Scarlett playback links for this track pair.
  for aux in {0..19}; do
    run pw-link -d "$out1" "$SCARLETT_PREFIX:playback_AUX$aux"
    run pw-link -d "$out2" "$SCARLETT_PREFIX:playback_AUX$aux"
  done

  # Mono-per-track: both channels to one hardware output.
  run pw-link "$out1" "$SCARLETT_PREFIX:playback_AUX$dest_aux"
  run pw-link "$out2" "$SCARLETT_PREFIX:playback_AUX$dest_aux"

  printf 'Mapped %s -> AUX%s (playback %s)\n' "$base" "$dest_aux" "$((dest_aux + 1))"
done

if [[ $APPLY -eq 1 ]]; then
  echo "Done."
else
  echo "Dry-run complete. Re-run with --apply to execute."
fi
