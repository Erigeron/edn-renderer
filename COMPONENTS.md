# Components DSL

This document defines the current Cirru EDN layout DSL consumed by `edn-renderer`
on the `genui` channel.

## Envelope Shape

A layout payload is a single Cirru EDN map.

Common fields:

- `:type` required, string
- `:children` optional, list of child nodes
- `:text` optional, string
- `:name` optional, string
- `:placeholder` optional, string
- `:series` optional, list of `{:label string :value number}` for charts

Example root:

```cirru
{}
  :type |card
  :text "|Demo Card"
  :children $ []
    {} (:type |badge) (:text |preview)
    {} (:type |divider)
    {} (:type |text) (:text "|Hello from renderer")
```

## Supported Nodes

### `column`

Vertical flex container.

Required fields:

- `:children`

Example:

```cirru
{}
  :type |column
  :children $ []
    {} (:type |text) (:text "|Line A")
    {} (:type |text) (:text "|Line B")
```

### `row`

Horizontal flex container with wrapping.

Required fields:

- `:children`

Example:

```cirru
{}
  :type |row
  :children $ []
    {} (:type |badge) (:text |left)
    {} (:type |badge) (:text |right)
```

### `card`

Bordered container with optional title.

Optional fields:

- `:text` for the card title
- `:children`

Example:

```cirru
{}
  :type |card
  :text "|Demo Card"
  :children $ []
    {} (:type |text) (:text "|Card body")
```

### `text`

Plain text block.

Required fields:

- `:text`

Example:

```cirru
{}
  :type |text
  :text |Hello
```

### `badge`

Small inline pill label.

Required fields:

- `:text`

Example:

```cirru
{}
  :type |badge
  :text |preview
```

### `divider`

Horizontal separator line.

No extra fields.

Example:

```cirru
{}
  :type |divider
```

### `markdown`

Structured analysis notes rendered from a text block.

Required fields:

- `:text`

Notes:

- headings starting with `#`, `##`, `###` are emphasized
- lines starting with `- ` render as bullets
- lines starting with `> ` render as quotes

Example:

```cirru
{}
  :type |markdown
  :text "|# Analysis\n- Revenue drift\n- Margin recovery\n> Review channel mix"
```

### `mermaid`

Mermaid source block for diagram-oriented analysis.

Required fields:

- `:text`

Notes:

- the current renderer shows Mermaid source in a styled code block
- this is useful for reviewing or iterating diagram prompts before adding a full diagram engine

Example:

```cirru
{}
  :type |mermaid
  :text "|flowchart TD\n  A[Signal] --> B[Hypothesis]\n  B --> C[Action]"
```

### `chart`

Simple horizontal bar chart for numeric comparisons.

Required fields:

- non-empty `:series`

Each series item must provide:

- `:label` string
- `:value` number

Example:

```cirru
{}
  :type |chart
  :series $ []
    {} (:label |North) (:value 42)
    {} (:label |South) (:value 27)
    {} (:label |West) (:value 35)
```

### `button`

Disabled preview button used to show intent in generated UI.

Required fields:

- `:text`

Example:

```cirru
{}
  :type |button
  :text |Confirm
```

### `input`

Disabled preview input field.

Required fields:

- at least one of `:name` or `:placeholder`

Optional fields:

- `:text` for preset value

Example:

```cirru
{}
  :type |input
  :name |email
  :placeholder |Email
```

## Validation Rules

The current validator enforces:

- root must be a map
- every node must have a string `:type`
- `column`, `row`, and `card` recursively validate `:children`
- `text`, `badge`, `button`, `markdown`, and `mermaid` require non-empty `:text`
- `chart` requires a non-empty `:series`, and every item must provide string `:label` plus numeric `:value`
- `input` requires `:name` or `:placeholder`

## Full Example

```cirru
{}
  :type |column
  :children $ []
    {} (:type |markdown) (:text "|# Analysis\n- Revenue drift\n- Margin recovery\n> Review channel mix")
    {} (:type |mermaid) (:text "|flowchart TD\n  A[Signal] --> B[Hypothesis]\n  B --> C[Action]")
    {} (:type |chart)
      :series $ []
        {} (:label |North) (:value 42)
        {} (:label |South) (:value 27)
        {} (:label |West) (:value 35)
```
