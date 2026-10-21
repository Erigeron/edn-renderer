#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

cd "$ROOT_DIR"
node - <<'EOF'
import * as core from './js-out/calcit.core.mjs'
import assert from 'node:assert/strict'
import { cache_renderer_channel_state, restore_renderer_channel_state, updater } from './js-out/app.updater.mjs'
import { validate_layout } from './js-out/app.comp.container.mjs'
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

// Real reload regression: EDN restores enum payloads but not their nominal prototype.
// Rebuild the application model from the saved DSL, including channel/workspace restore.
const stateTags = core.init_tags(['renderer', 'layout', 'layout-dsl', 'workspace-entry', 'layout-data'])
const dsl = core.parse_cirru_edn('{} (:type |text) (:text "|031 persisted layout 🐈")')
const layout = validate_layout(dsl)
const entry = core._$n__$M_(stateTags['layout-dsl'], dsl, stateTags['layout-data'], layout)
let persistedRenderer = core.assoc(read(store, stateTags.renderer), stateTags.layout, layout)
persistedRenderer = core.assoc(persistedRenderer, stateTags['layout-dsl'], dsl)
persistedRenderer = core.assoc(persistedRenderer, stateTags['workspace-entry'], entry)
persistedRenderer = cache_renderer_channel_state(persistedRenderer, channel)
const serialized = core.format_cirru_edn(core.assoc(store, stateTags.renderer, persistedRenderer))
const parsed = core.parse_cirru_edn(serialized)
assert.equal(read(read(parsed, stateTags.renderer), stateTags.layout).enumPrototype, null)
const hydrated = updater(store, core._$o__$o_(core.newTag('hydrate-storage'), parsed), 'synthetic-hydrate', 0)
const hydratedRenderer = read(hydrated, stateTags.renderer)
assert.equal(read(hydratedRenderer, stateTags.layout).enumPrototype, layout.enumPrototype)
const restoredChannel = restore_renderer_channel_state(hydratedRenderer, channel)
assert.equal(read(restoredChannel, stateTags.layout).enumPrototype, layout.enumPrototype)
const workspace = updater(hydrated, core._$o__$o_(core.newTag('load-workspace-report')), 'synthetic-workspace', 0)
assert.equal(read(read(workspace, stateTags.renderer), stateTags.layout).enumPrototype, layout.enumPrototype)
console.log('persisted layout, channel and workspace nominal restoration passed')
EOF
