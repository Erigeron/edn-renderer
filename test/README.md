# Test Assets

This directory keeps partial automation for renderer validation.

## Strategy

Validation is split into 3 levels:

1. renderer build checks
2. relay-to-renderer scripted checks
3. browser-assisted partial UI checks

The main design choice is to avoid depending on browser DOM details when the renderer can already export a stable trimmed tree.

Expected usage:

- local development: run levels 1, 2, and selected level-3 smoke scripts to catch obvious behavior regressions
- CI: only run level 1 plus the renderer-side snapshot script; do not require browser style or DOM-structure assertions

## Renderer-side snapshot interface

Use the renderer request below for most scripted validation:

```cirru
{}
  :op :snapshot
```

Optional subtree request:

```cirru
{}
  :op :snapshot
  :path |2.1
```

This returns a trimmed tree rather than the full DSL. It is intentionally closer to an assertion snapshot than a debugging dump.

Recommended usage:

1. send a case payload
2. request `:snapshot`
3. grep the returned tree for stable lines such as node type, path, child-count, chart kind, mermaid line count, or math expr tag

Prefer a dedicated test channel such as `snapshot-e2e` for this flow. If an older page is still subscribed to the same channel, relay may receive an outdated ack from a stale HMR closure first.

## Files

- [test/cases/mixed-dashboard.cirru](cases/mixed-dashboard.cirru): mixed markdown, chart, and Mermaid case
- [test/cases/math-quadratic.cirru](cases/math-quadratic.cirru): MathML case
- [test/ci-renderer-dsl.sh](ci-renderer-dsl.sh): CI entrypoint for renderer DSL logic validation
- [test/channel-cache-smoke.sh](channel-cache-smoke.sh): pure renderer-state regression check for channel switching cache restore
- [test/library-smoke.sh](library-smoke.sh): local-only Library and workspace switching smoke test
- [test/snapshot-smoke.sh](snapshot-smoke.sh): scripted relay and renderer validation using `:snapshot`
- [test/ui-basic-smoke.sh](ui-basic-smoke.sh): partial browser automation using `chrome-devtools`

## Conventions

- prefer Calcit-side protocol support over custom JS helpers when possible
- keep orchestration in bash
- treat browser automation as partial smoke coverage, not as the only source of truth
- browser scripts should assert text-level behavior and feature availability, not exact style or DOM shape
