#!/usr/bin/env bash

set -euo pipefail

PAGE_URL=${PAGE_URL:-http://127.0.0.1:3010/?channel=genui&server=ws://127.0.0.1:9100}

extract_uid() {
  local label=$1
  local snapshot=$2
  awk -v label="$label" '
    index($0, label) {
      match($0, /uid=[^ ]+/)
      if (RSTART > 0) {
        print substr($0, RSTART + 4, RLENGTH - 4)
        exit
      }
    }
  ' <<<"$snapshot"
}

assert_snapshot_contains() {
  local snapshot=$1
  local text=$2
  if ! grep -Fq "$text" <<<"$snapshot"; then
    echo "Missing snapshot text: $text" >&2
    exit 1
  fi
}

chrome-devtools new_page "$PAGE_URL" >/dev/null
snapshot=$(chrome-devtools take_snapshot)

assert_snapshot_contains "$snapshot" 'StaticText "EDN Renderer"'
assert_snapshot_contains "$snapshot" 'StaticText "Channel: genui"'

library_uid=$(extract_uid 'button "Library"' "$snapshot")
history_uid=$(extract_uid 'button "History' "$snapshot")

if [[ -z "$library_uid" || -z "$history_uid" ]]; then
  echo 'Could not locate Library or History button in browser snapshot' >&2
  exit 1
fi

chrome-devtools click "$history_uid" >/dev/null
history_snapshot=$(chrome-devtools take_snapshot)
assert_snapshot_contains "$history_snapshot" 'StaticText "Detail"'

chrome-devtools click "$library_uid" >/dev/null
library_snapshot=$(chrome-devtools take_snapshot)
assert_snapshot_contains "$library_snapshot" 'StaticText "Library Items"'

echo 'ui basic smoke passed'