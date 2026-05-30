#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
RELAY_BIN=${RELAY_BIN:-/Users/chenyong/repo/worktools/cirru_edn_relay/target/debug/edn-relay}
SERVER=${SERVER:-ws://127.0.0.1:9100}
CHANNEL=${CHANNEL:-snapshot-e2e}

send_payload() {
  local payload_file=$1
  "$RELAY_BIN" send --server "$SERVER" --channel "$CHANNEL" "$(cat "$payload_file")"
}

snapshot_payload() {
  cat <<'EOF'
{}
  :op :snapshot
EOF
}

snapshot_subtree_payload() {
  local path=$1
  cat <<EOF
{}
  :op :snapshot
  :path |$path
EOF
}

assert_contains() {
  local haystack=$1
  local needle=$2
  if ! grep -Fq "$needle" <<<"$haystack"; then
    echo "Expected to find: $needle" >&2
    exit 1
  fi
}

echo '[1/4] Send mixed dashboard case'
send_output=$(send_payload "$ROOT_DIR/test/cases/mixed-dashboard.cirru")
assert_contains "$send_output" '(:status :ok)'

echo '[2/4] Verify stable root snapshot'
snapshot_output=$("$RELAY_BIN" send --server "$SERVER" --channel "$CHANNEL" "$(snapshot_payload)")
assert_contains "$snapshot_output" '(:kind :snapshot)'
assert_contains "$snapshot_output" '(:type |column)'
assert_contains "$snapshot_output" '(:path |2.2)'
assert_contains "$snapshot_output" '(:type |mermaid)'
assert_contains "$snapshot_output" '(:kind |line)'

echo '[3/4] Verify subtree snapshot'
subtree_output=$("$RELAY_BIN" send --server "$SERVER" --channel "$CHANNEL" "$(snapshot_subtree_payload '1')")
assert_contains "$subtree_output" '(:path |1)'
assert_contains "$subtree_output" '(:title "|Weekly Report")'

echo '[4/4] Send MathML case and verify snapshot'
math_send_output=$(send_payload "$ROOT_DIR/test/cases/math-quadratic.cirru")
assert_contains "$math_send_output" '(:status :ok)'
math_snapshot_output=$("$RELAY_BIN" send --server "$SERVER" --channel "$CHANNEL" "$(snapshot_payload)")
assert_contains "$math_snapshot_output" '(:type |math)'
assert_contains "$math_snapshot_output" '(:expr-tag |mfrac)'

echo 'snapshot smoke passed'