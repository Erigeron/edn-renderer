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
- `text`, `badge`, and `button` require non-empty `:text`
- `input` requires `:name` or `:placeholder`

## Full Example

```cirru
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
```
