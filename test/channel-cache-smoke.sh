#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

cd "$ROOT_DIR"
node - <<'EOF'
import * as core from './js-out/calcit.core.mjs'
import { cache_renderer_channel_state, restore_renderer_channel_state } from './js-out/app.updater.mjs'
import { store } from './js-out/app.schema.mjs'

const tags = core.init_tags(['renderer', 'layout-id', 'workspace-entry', 'channel-cache'])
const read = (value, key) => core.option_$o_unwrap(core.get(value, key))
const channel = core._PCT_some('alpha')

let renderer = read(store, tags.renderer)
renderer = core.assoc(renderer, tags['layout-id'], 'layout-a')
renderer = core.assoc(renderer, tags['workspace-entry'], core.parse_cirru_edn('{} (:layout-id |layout-a)'))

renderer = cache_renderer_channel_state(renderer, channel)
renderer = core.assoc(renderer, tags['layout-id'], null)
renderer = core.assoc(renderer, tags['workspace-entry'], null)
renderer = restore_renderer_channel_state(renderer, channel)

const restoredLayoutId = read(renderer, tags['layout-id'])
const restoredWorkspaceEntry = read(renderer, tags['workspace-entry'])
const restoredWorkspaceLayoutId = read(restoredWorkspaceEntry, tags['layout-id'])
const cachedChannels = core.count(core.keys(read(renderer, tags['channel-cache'])))

if (restoredLayoutId !== 'layout-a') {
  console.error('Expected layout-id to be restored for alpha, got:', restoredLayoutId)
  process.exit(1)
}

if (restoredWorkspaceLayoutId !== 'layout-a') {
  console.error('Expected workspace-entry layout-id to be restored for alpha, got:', restoredWorkspaceLayoutId)
  process.exit(1)
}

if (cachedChannels < 1) {
  console.error('Expected at least one cached channel entry, got:', cachedChannels)
  process.exit(1)
}

console.log('channel cache smoke passed')
EOF
