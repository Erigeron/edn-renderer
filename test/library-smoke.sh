#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
RELAY_BIN=${RELAY_BIN:-/Users/chenyong/repo/worktools/cirru_edn_relay/target/debug/edn-relay}
SERVER=${SERVER:-ws://127.0.0.1:9100}
CHANNEL=${CHANNEL:-library-e2e}
PAGE_URL=${PAGE_URL:-http://127.0.0.1:3010/?channel=${CHANNEL}&server=${SERVER}}

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

send_payload_file() {
  local payload_file=$1
  "$RELAY_BIN" send --server "$SERVER" --channel "$CHANNEL" "$(cat "$payload_file")" >/dev/null
}

wait_for_receiver() {
  "$RELAY_BIN" status --server "$SERVER" --channel "$CHANNEL" >/dev/null
}

count_saved_files() {
  find "$HOME/.config/ed-relay/$CHANNEL" -maxdepth 1 -name '*.cirru' 2>/dev/null | wc -l | tr -d ' '
}

extract_first_saved_report_uid() {
  local snapshot=$1
  awk '
    /StaticText ".*\.cirru"/ {
      match($0, /uid=[^ ]+/)
      if (RSTART > 0) {
        print substr($0, RSTART + 4, RLENGTH - 4)
        exit
      }
    }
  ' <<<"$snapshot"
}

chrome-devtools new_page "$PAGE_URL" >/dev/null
snapshot=$(chrome-devtools take_snapshot)

assert_snapshot_contains "$snapshot" 'StaticText "EDN Renderer"'
assert_snapshot_contains "$snapshot" "StaticText \"Channel: $CHANNEL\""

wait_for_receiver
send_payload_file "$ROOT_DIR/test/cases/mixed-dashboard.cirru"
before_count=$(count_saved_files)
snapshot=$(chrome-devtools take_snapshot)

save_uid=$(extract_uid 'button "Save"' "$snapshot")
library_uid=$(extract_uid 'button "Library"' "$snapshot")

if [[ -z "$save_uid" || -z "$library_uid" ]]; then
  echo 'Could not locate Save or Library button in browser snapshot' >&2
  exit 1
fi

chrome-devtools click "$save_uid" >/dev/null
after_count=$(count_saved_files)
if [[ "$after_count" -le "$before_count" ]]; then
  echo 'Save did not create a new persisted report file' >&2
  exit 1
fi

chrome-devtools click "$library_uid" >/dev/null
library_snapshot=$(chrome-devtools take_snapshot)
assert_snapshot_contains "$library_snapshot" 'StaticText "Library Items"'
assert_snapshot_contains "$library_snapshot" 'StaticText "current workspace"'

saved_report_uid=$(extract_first_saved_report_uid "$library_snapshot")
workspace_uid=$(extract_uid "StaticText \"$CHANNEL / current workspace\"" "$library_snapshot")

if [[ -z "$saved_report_uid" || -z "$workspace_uid" ]]; then
  echo 'Could not locate saved report entry or current workspace entry in Library snapshot' >&2
  exit 1
fi

chrome-devtools click "$saved_report_uid" >/dev/null
saved_snapshot=$(chrome-devtools take_snapshot)
assert_snapshot_contains "$saved_snapshot" 'StaticText "Status: loaded"'

chrome-devtools click "$workspace_uid" >/dev/null
workspace_snapshot=$(chrome-devtools take_snapshot)
assert_snapshot_contains "$workspace_snapshot" 'StaticText "Status: workspace"'

echo 'library smoke passed'

workspace_uid=$(extract_uid 'StaticText "'