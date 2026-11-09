#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

cd "$ROOT_DIR"
node - <<'EOF'
import * as core from './js-out/calcit.core.mjs'
import assert from 'node:assert/strict'
import { cache_renderer_channel_state, restore_renderer_channel_state, updater } from './js-out/app.updater.mjs'
import { build_echarts_option, validate_layout } from './js-out/app.comp.container.mjs'
import { store } from './js-out/app.schema.mjs'

const tags = core.init_tags(['renderer', 'layout-id', 'workspace-entry', 'channel-cache'])
const read = (value, key) => core.option_$o_unwrap(core.get(value, key))
const channel = core._PCT__$o__$o_(core.Option, core.newTag('some'), 'alpha')

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
const cachedChannels = core.keys(read(renderer, tags['channel-cache'])).len()

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
const dsl = core.parse_cirru_edn(`{} (:type |column)
  :children $ []
    {} (:type |text) (:text "|031 persisted layout 🐈")
    {} (:type |chart) (:kind |pie) (:title |Revenue)
      :series $ [] ({} (:label |zero) (:value 0)) ({} (:label |loss) (:value -3))`)
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
const restoredLayout = read(read(workspace, stateTags.renderer), stateTags.layout)
assert.equal(restoredLayout.enumPrototype, layout.enumPrototype)
const [text, chart] = restoredLayout.extra[0].toArray()
assert.equal(text.extra[0], '031 persisted layout 🐈')
const [kind, title, points] = chart.extra
const options = build_echarts_option(points, kind, title)
const series = read(options, core.newTag('series')).get(0)
assert.equal(read(series, core.newTag('type')), 'pie')
assert.equal(read(read(options, core.newTag('title')), core.newTag('text')), 'Revenue')
assert.deepEqual(
  read(series, core.newTag('data')).toArray().map(point =>
    [read(point, core.newTag('name')), read(point, core.newTag('value'))]),
  [['zero', 0], ['loss', -3]],
)

const fallback = validate_layout(core.parse_cirru_edn('{} (:type |chart) (:kind |unknown) (:title |) (:series ([]))'))
const [fallbackKind, fallbackTitle, fallbackPoints] = fallback.extra
const fallbackOptions = build_echarts_option(fallbackPoints, fallbackKind, fallbackTitle)
assert.equal(read(read(fallbackOptions, core.newTag('series')).get(0), core.newTag('type')), 'bar')
assert.equal(core._$n_map_$o_contains_$q_(fallbackOptions, core.newTag('title')), false)

for (const chartType of ['bar', 'line', 'scatter']) {
  const axisChart = validate_layout(core.parse_cirru_edn(`{} (:type |chart) (:kind |${chartType})
  :series $ [] ({} (:label |zero) (:value 0)) ({} (:label |loss) (:value -3))`))
  const [kind, title, points] = axisChart.extra
  const options = build_echarts_option(points, kind, title)
  const series = read(options, core.newTag('series')).get(0)
  assert.equal(read(series, core.newTag('type')), chartType)
  assert.deepEqual(read(series, core.newTag('data')).toArray(), [0, -3])
  assert.deepEqual(read(read(options, core.newTag('xAxis')), core.newTag('data')).toArray(), ['zero', 'loss'])
}

console.log('persisted layout, channel and workspace nominal restoration passed')
EOF
