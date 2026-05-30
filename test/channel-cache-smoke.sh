#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

cd "$ROOT_DIR"
node - <<'EOF'
import * as core from './js-out/calcit.core.mjs'
import { cache_renderer_channel_state, restore_renderer_channel_state } from './js-out/app.updater.mjs'
import { store } from './js-out/app.schema.mjs'

const tags = core.init_tags(['renderer', 'layout-id', 'workspace-entry', 'channel-cache'])

let renderer = core.get(store, tags.renderer)
renderer = core.assoc(renderer, tags['layout-id'], 'layout-a')
renderer = core.assoc(renderer, tags['workspace-entry'], core._$n__$M_(tags['layout-id'], 'layout-a'))

renderer = cache_renderer_channel_state(renderer, 'alpha')
renderer = core.assoc(renderer, tags['layout-id'], null)
renderer = core.assoc(renderer, tags['workspace-entry'], null)
renderer = restore_renderer_channel_state(renderer, 'alpha')

const restoredLayoutId = core.get(renderer, tags['layout-id'])
const restoredWorkspaceEntry = core.get(renderer, tags['workspace-entry'])
const restoredWorkspaceLayoutId = core.get(restoredWorkspaceEntry, tags['layout-id'])
const cachedChannels = core.count(core.keys(core.get(renderer, tags['channel-cache'])))

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