# edn-renderer

`edn-renderer` is the browser frontend for the `edn-relay` workflow.

It keeps a websocket connection to the relay, subscribes to a chosen channel
such as `genui`, stores the incoming Cirru EDN layout DSL, renders the layout,
and sends an ack back to the CLI.

The sidebar is collapsed by default so more horizontal space is reserved for the
rendered result.

## Current Status

The current implementation already supports the full loop:

1. start `edn-relay serve`
2. open `edn-renderer` in a browser
3. run `edn-relay send --channel genui <LAYOUT>` from the CLI
4. render the DSL in the page
5. confirm success with a returned ack payload and layout id

It also supports inspection and local mutation of the currently rendered layout
through relay requests, so a CLI agent can read a summarized tree, fetch one
node's full DSL, and patch or replace that node without resending the whole page.

Reference screenshot:

- [artifacts/edn-renderer-genui-final.png](artifacts/edn-renderer-genui-final.png)

## Development

```bash
corepack enable && corepack prepare yarn@4.12.0 --activate
yarn install

cr js
yarn vite --host 127.0.0.1 --port 3010
```

Published bootstrap page:

- `https://r.tiye.me/Erigeron/edn-renderer/`
- supports `?channel=<NAME>` to preselect a channel
- supports `?server=<WS_URL>` or `?port=<PORT>` to override the relay websocket target

If Vite fails because `rolldown` native bindings are missing, run `yarn install`
again so the unplugged package is materialized on disk.

## End-to-End Usage

Start the frontend dev server:

```bash
yarn vite --host 127.0.0.1 --port 3010
```

Open the page in a browser. In parallel, run the relay:

```bash
edn-relay serve
```

If you want the published bootstrap page instead of a local dev server, run:

```bash
edn-relay open-published --channel genui
```

Then send a layout DSL from the CLI:

```bash
LAYOUT=$(cat <<'EOF'
{}
  :type |card
  :text "|CLI Demo"
  :children $ []
    {} (:type |badge) (:text |preview)
    {} (:type |divider)
    {} (:type |text) (:text "|Hello from installed CLI")
    {} (:type |row)
      :children $ []
        {} (:type |button) (:text |Confirm)
        {} (:type |input) (:name |email) (:placeholder |Email)
EOF
)

edn-relay send --channel genui "$LAYOUT"
```

Expected result:

- CLI prints an `ack` frame whose payload contains `:status |ok` and `:layout_id`
- the page shows the layout id and request id
- the renderer preview updates immediately

## Save And Library

When a meaningful layout is already loaded in the page, the top bar exposes 2
extra actions:

- `Save`: asks relay to persist the current report under `~/.config/ed-relay/<channel>/`
- `Library`: opens the saved report list for the current channel and lets you load one entry back into the preview

The browser does not write local files directly. Instead it sends a generic
relay request to the reserved internal channel `__relay_store__`, and relay
stores opaque Cirru EDN files on disk.

Validated flow:

1. send a layout into `genui`
2. click `Save`
3. confirm a new `.cirru` file appears under `~/.config/ed-relay/genui/`
4. click `Library`
5. click a saved report entry
6. confirm the preview loads the saved layout back into the page

## Layout Inspection And Editing

Once a layout is already loaded in the page, you can inspect and edit it with
small relay payloads.

Get a token-efficient layout summary tree:

```bash
edn-relay send --channel genui '
{}
  :op :layout
'
```

Inspect one node by 1-based path such as `2.1`:

```bash
edn-relay send --channel genui '
{}
  :op :node
  :path |2.1
'
```

Patch one node in place by merging a subset of fields:

```bash
edn-relay send --channel genui '
{}
  :op :patch
  :path |1
  :changes $ {}
    :text |Updated
'
```

Replace one node's DSL completely:

```bash
edn-relay send --channel genui '
{}
  :op :replace
  :path |2.1
  :node $ {}
    :type |text
    :text |Replaced
'
```

Path rules:

- `root` means the whole layout
- `1`, `2`, `3` address root children with 1-based indices
- `2.1` means the first child under the second root child
- `layout` returns summaries, while `node` returns the full DSL for that path

## DSL Components

Current built-in nodes:

- `column`
- `row`
- `card`
- `text`
- `badge`
- `divider`
- `markdown`
- `mermaid`
- `chart`
- `button`
- `input`

Detailed DSL rules and examples live in [COMPONENTS.md](COMPONENTS.md).

Current analysis-oriented rendering behavior:

- `markdown` renders headings, bullets, quotes, and wrapped paragraphs
- `mermaid` renders a Mermaid SVG diagram from the provided source text
- `chart` renders a compact horizontal bar chart from `:series`

## Validation

Compile the Calcit app with:

```bash
cr js
```

For a dedicated renderer, CLI, and browser validation checklist, see [TESTING.md](TESTING.md).

For isolated browser validation, use the `chrome-devtools` workflow described in
[Agents.md](Agents.md).

## License

MIT
