# edn-renderer

`edn-renderer` is the browser frontend for the `edn-relay` workflow.

It keeps a websocket connection to the relay, listens on the `genui` channel,
stores the incoming Cirru EDN layout DSL, renders the layout, and sends an ack
back to the CLI.

The sidebar is collapsed by default so more horizontal space is reserved for the
rendered result.

## Current Status

The current implementation already supports the full loop:

1. start `edn-relay serve`
2. open `edn-renderer` in a browser
3. run `edn-relay genui <LAYOUT>` from the CLI
4. render the DSL in the page
5. confirm success with a returned layout id

Reference screenshot:

- [artifacts/edn-renderer-genui-final.png](artifacts/edn-renderer-genui-final.png)

## Development

```bash
corepack enable && corepack prepare yarn@4.12.0 --activate
yarn install

cr js
yarn vite --host 127.0.0.1 --port 3010
```

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

edn-relay genui --server ws://127.0.0.1:9001 "$LAYOUT"
```

Expected result:

- CLI prints `genui ok <layout-id>`
- the page shows the layout id and request id
- the renderer preview updates immediately

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
- `mermaid` currently renders a styled source block for analysis and prompt iteration
- `chart` renders a compact horizontal bar chart from `:series`

## Validation

Compile the Calcit app with:

```bash
cr js
```

For isolated browser validation, use the `chrome-devtools` workflow described in
[Agents.md](Agents.md).

## License

MIT
