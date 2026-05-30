# Testing Guide

This repository already had validation notes spread across [README.md](README.md), [SKILL.md](SKILL.md), and [Agents.md](Agents.md), but it did not have one dedicated test workflow document.

This file is the canonical checklist for validating the renderer end to end.

## Local vs CI

Use 2 different standards for validation:

- local validation should aim to catch functional problems quickly, even if the checks are only partial
- CI validation only needs scripted renderer DSL logic checks; it does not need browser style correctness or DOM-structure correctness

Practical rule:

- local: run `cr js`, snapshot-based renderer checks, and partial browser smoke checks
- CI: run the snapshot-based renderer DSL script only

## Latest Verified Run

Validated on 2026-05-30 against a local Vite page and a relay listening on `ws://127.0.0.1:9100`.

Observed results:

- `cr js` succeeded
- `edn-relay status/help/skill --channel genui` all returned expected payloads
- mixed dashboard case rendered markdown, Mermaid, and chart content successfully
- `:layout`, `:node`, `:patch`, and `:replace` all returned successful acks
- `Save` created `.cirru` files under `~/.config/ed-relay/genui/`
- `Library` showed persisted reports plus one local `current workspace` snapshot entry
- switching from a saved report back to `current workspace` restored the local preview state
- MathML block rendering succeeded for the quadratic-formula case

Known non-blocking observations from that run:

- ECharts logged one initial size warning before the container settled
- the active `genui` channel had more than one receiver, so relay logged duplicate-ack warnings
- browser tooling reported one accessibility issue about a form field without an id or name attribute

When validating newly added renderer request handlers, prefer a fresh page or a dedicated channel such as `snapshot-e2e`; older receiver tabs can keep stale HMR closures and reply with outdated request behavior.

## Scope

The validation flow is split into 3 layers:

1. Renderer build validation
2. Relay CLI capability validation
3. Browser UI and interaction validation

Run them in this order so failures stay easy to localize.

## 1. Prerequisites

Renderer workspace:

```bash
cr js
yarn vite --host 127.0.0.1 --port 3010
```

Relay workspace:

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- serve --bind 127.0.0.1:9100
```

Browser:

```bash
chrome-devtools status
chrome-devtools start --headless false
chrome-devtools new_page 'http://127.0.0.1:3010?channel=genui&server=ws://127.0.0.1:9100'
```

Expected readiness signals:

- `cr js` succeeds
- Vite serves the page on `127.0.0.1:3010`
- relay is listening on `127.0.0.1:9100`
- browser page shows channel `genui`
- browser console has no fatal initialization error

## 2. Renderer Build Validation

Use this as the narrowest pre-flight check after any Calcit change.

```bash
cr js
```

Use this before browser checks when dependencies or bundling-related code changed.

```bash
yarn vite build --base=./
```

Expected result:

- build succeeds
- generated `js-out/` files update cleanly
- existing warnings may be recorded separately, but new failures must be treated as regressions

## 3. Relay CLI Validation

These checks verify that the renderer is reachable and that protocol-facing commands still work.

### 3.1 Status

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- status --server ws://127.0.0.1:9100 --channel genui
```

Expected result:

- returns renderer name `edn-renderer`
- includes page URL
- includes commands such as `send`, `help`, `skill`, `status`, `open`

### 3.2 Help and Skill

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- help --server ws://127.0.0.1:9100 --channel genui
cargo run -- help --server ws://127.0.0.1:9100 --channel genui components
cargo run -- skill --server ws://127.0.0.1:9100 --channel genui workflow
```

Expected result:

- `help` returns a short overview by default
- topic queries return narrowed content instead of the whole manual
- `skill workflow` returns the intended workflow summary

### 3.3 Send Layout Payloads

Simple smoke payload:

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- send --server ws://127.0.0.1:9100 --channel genui '
{}
  :type |card
  :text "|CLI Demo"
  :children $ []
    {} (:type |badge) (:text |preview)
    {} (:type |text) (:text "|Hello from CLI")
'
```

Expected result:

- relay prints an `ack` with `:status :ok`
- payload includes a `:layout_id`
- browser preview updates immediately

## 4. Browser UI Basic Validation

Once the page is open, validate the visible browser workflow.

This layer is intentionally functional rather than visual. The goal is to catch broken behavior, not to assert exact styling or DOM structure.

### 4.1 Top bar and preview

Check these items:

- channel badge shows the selected channel
- relay badge becomes `ready`
- preview area switches from waiting state to rendered layout after a send
- `History` count increases when frames arrive

### 4.2 History drawer

Check these items:

- clicking `History` opens the drawer
- left list shows recent relay frames
- selecting one entry updates the detail panel
- raw relay frame text is visible in the detail textarea

### 4.3 Library drawer

Check these items:

- `Save` is enabled when a valid layout is loaded
- clicking `Save` persists an entry for the current channel
- clicking `Library` opens the saved report list
- the drawer shows one local `current workspace` snapshot entry when a workspace layout exists
- clicking a saved report switches the preview to that saved layout
- clicking `current workspace` switches the preview back to the local workspace snapshot
- `current workspace` is only a local item and must not increase the saved report count

## 5. Layout Editing Validation

These checks verify the request-response editing flow after a non-trivial layout has already been loaded.

### 5.1 Summary tree

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- send --server ws://127.0.0.1:9100 --channel genui '
{}
  :op :layout
'
```

Expected result:

- returns `:kind :layout`
- includes `:summary`
- summary nodes contain `:path`, `:type`, and `:child-count`

### 5.1b Stable snapshot tree

Use this for most scripted CLI checks. It intentionally returns a trimmed tree rather than the full DSL.

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- send --server ws://127.0.0.1:9100 --channel genui '
{}
  :op :snapshot
'
```

Expected result:

- returns `:kind :snapshot`
- includes `:tree`
- tree only contains stable summary fields such as `:path`, `:type`, `:child-count`, and a small set of node-specific metadata
- scripts can grep this payload without depending on the full layout DSL or browser DOM

### 5.2 Read one node

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- send --server ws://127.0.0.1:9100 --channel genui '
{}
  :op :node
  :path |1
'
```

Expected result:

- returns `:kind :node`
- includes `:dsl`, `:source`, and `:summary`

### 5.3 Patch one node

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- send --server ws://127.0.0.1:9100 --channel genui '
{}
  :op :patch
  :path |1
  :changes $ {}
    :text |Updated title
'
```

Expected result:

- returns `:kind :patch`
- preview updates without resending the whole layout
- history records the patch request and ack

### 5.4 Replace one node

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- send --server ws://127.0.0.1:9100 --channel genui '
{}
  :op :replace
  :path |1.2
  :node $ {}
    :type |markdown
    :text "|## Replaced\n- alpha\n- beta"
'
```

Expected result:

- returns `:kind :replace`
- browser preview updates in place
- response includes the updated node summary

## 6. Complex Scenario Cases

Use these payloads when validating richer renderer capabilities after substantial changes.

### 6.1 Mixed dashboard case

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- send --server ws://127.0.0.1:9100 --channel genui '
{}
  :type |column
  :children $ []
    {} (:type |card) (:text "|Weekly Report")
      :children $ []
        {} (:type |text) (:text "|System health summary")
        {} (:type |badge) (:text |healthy)
        {} (:type |divider)
        {} (:type |markdown) (:text "|## Notes\n- renderer ok\n- relay ok\n> investigate warnings later")
    {} (:type |row)
      :children $ []
        {} (:type |chart) (:kind |line) (:title "|Traffic")
          :series $ []
            {} (:label |Mon) (:value 120)
            {} (:label |Tue) (:value 132)
            {} (:label |Wed) (:value 148)
        {} (:type |mermaid) (:text "|flowchart LR\n  CLI --> Relay\n  Relay --> Renderer\n  Renderer --> Browser")
'
```

Verify:

- markdown block renders headings, bullets, and quote text
- chart renders without console failures
- Mermaid block renders to SVG instead of staying on placeholder text

### 6.2 Math case

```bash
cd /Users/chenyong/repo/worktools/cirru_edn_relay
cargo run -- send --server ws://127.0.0.1:9100 --channel genui '
{}
  :type |math
  :display |block
  :expr $ [] |mfrac
    [] |mrow
      [] |mo |−
      [] |mi |b
      [] |mo |±
      [] |msqrt
        [] |mrow
          [] |msup
            [] |mi |b
            [] |mn |2
          [] |mo |−
          [] |mn |4
          [] |mi |a
          [] |mi |c
    [] |mrow
      [] |mn |2
      [] |mi |a
'
```

Verify:

- browser shows rendered MathML output
- no validation error banner appears
- relay ack stays successful

## 7. Failure Triage

Use this mapping when a validation step fails:

- `cr js` fails: fix renderer snapshot or Calcit syntax first
- `status/help/skill/send` fails before ack: inspect relay server and selected channel
- browser page stays in waiting state: inspect page URL channel and websocket target
- Mermaid or chart renders fail while ack succeeds: inspect browser console and DOM output
- library flow is wrong but send flow is correct: inspect `__relay_store__` request path and drawer state

## 8. Minimum Regression Set

For small changes, run at least this subset:

1. `cr js`
2. `cargo run -- status --server ws://127.0.0.1:9100 --channel genui`
3. one `send` smoke payload
4. one browser snapshot check

For state-management or drawer changes, also include:

1. `Save`
2. `Library`
3. workspace snapshot switching
4. one `:patch` request

## 9. Test Directory Layout

The repository keeps partial automation assets under [test/README.md](test/README.md).

- prefer renderer-side `:snapshot` checks for scripted CLI validation
- keep bash orchestration under `test/*.sh`
- keep reusable Cirru payloads under `test/cases/`
- keep browser automation partial and pragmatic; use `chrome-devtools` for stable checks such as page open, top-bar text, drawer text, and saved-report switching

## 10. Recommended Commands

Local functional smoke:

```bash
cr js
bash test/snapshot-smoke.sh
PAGE_URL='http://127.0.0.1:3013/?channel=genui&server=ws://127.0.0.1:9100' bash test/ui-basic-smoke.sh
PAGE_URL='http://127.0.0.1:3013/?channel=library-e2e&server=ws://127.0.0.1:9100' bash test/library-smoke.sh
```

CI renderer DSL validation:

```bash
cr js
bash test/ci-renderer-dsl.sh
```

That CI entrypoint currently covers:

- snapshot-based renderer DSL checks
- pure renderer-state regression for channel cache restore on switch-away and switch-back
