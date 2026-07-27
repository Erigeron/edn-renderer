# RFC: Mermaid Rendering Stability in edn-renderer

## Status

Accepted

## Context

`edn-renderer` 增加 `mermaid` 节点后，页面一度出现两类问题：

1. 图表短暂闪一下后变空白。
2. 浏览器控制台持续出现 `Uncaught (in promise)`，即使 Mermaid 库本身已经加载。

这类问题容易在切换编辑器或丢失对话历史后重复出现，因此需要把诊断结论沉淀下来。

## Symptoms

- `.mermaid-output` 初始能看到占位文案，但渲染后 SVG 会被清空。
- 控制台出现两次 `Uncaught (in promise) (0 args)`。
- 直接调用渲染函数时，能看到 `assoc does not work on nil for: <source> :rendering`。

## Root Causes

### 1. Respo virtual DOM clears imperative SVG updates

Mermaid 通过命令式方式写入 `output.innerHTML = svg`。如果同一个容器在 Respo 里还有普通 children，后续 reactive re-render 会继续做 child reconciliation，把已经写进去的 SVG 清掉。

结论：`.mermaid-output` 不能同时承载命令式 SVG 和普通虚拟 DOM children。

### 2. Empty Calcit map literal is not safe as a mutable atom base

在当前编译链中，空 map 字面量 `{}` 会编译成 JS 侧的 `$clt._$M_`，而这个值在运行时是 `undefined`。

因此：

- `defatom *rendered-svgs {}` 看起来像初始化为空 map。
- 但后续执行 `assoc @*rendered-svgs source :rendering` 时，实际是在对 `nil` 做 `assoc`。
- 这个异常发生在 async 函数里且早于 `await` 之后的错误处理，最终表现为 `Uncaught (in promise)`。

结论：不要把裸 `{}` 当作后续要 `assoc` 的 atom 初始值。

## Decision

采用以下实现约定：

1. 用缓存 atom 保存 Mermaid source 到渲染状态的映射。
2. `.mermaid-output` 只用 `:innerHTML` 承载占位文案或最终 SVG，不再放任何虚拟 DOM children。
3. 在真正调用 `mermaid.render` 前，先把对应 source 写成 `:rendering`，作为并发锁。
4. atom 初始值使用带占位键的 map，例如 `{} (:_init_ true)`，确保运行时拿到的是可 `assoc` 的 `CalcitMap`。

## Implemented Shape

关键实现形态如下：

```cirru
defatom *rendered-svgs $ {} (:_init_ true)

defcomp comp-mermaid-block (text)
  let
      payload $ build-mermaid-render-payload text
      svg-str $ if (:empty? payload) nil
        let
            result $ get @*rendered-svgs (:source payload)
          if (string? result) result nil
    [] (effect-mermaid text)
      div
        {} (:class-name |mermaid-host)
        div
          {}
            :class-name |mermaid-output
            :innerHTML $ if (nil? svg-str) "|Rendering Mermaid diagram..." svg-str
```

```cirru
defn render-mermaid-on (el payload)
  hint-fn $ {} (:async true)
  let
      source $ :source payload
      graph-id $ :graph-id payload
      output $ .!querySelector el |.mermaid-output
    if (nil? output) (.!warn js/console "|[mermaid] missing .mermaid-output" el)
      if (some? (get @*rendered-svgs source))
        .!debug js/console "|[mermaid] skip rendered"
        do
          reset! *rendered-svgs (assoc @*rendered-svgs source :rendering)
          ensure-mermaid!
          let
              render-fn $ .-render mermaid-lib
            try
              let
                  result $ js-await (.!call render-fn mermaid-lib graph-id source)
                  svg $ .-svg result
                do
                  set! (.-innerHTML output) svg
                  reset! *rendered-svgs (assoc @*rendered-svgs source svg)
              fn (error)
                do
                  reset! *rendered-svgs (assoc @*rendered-svgs source false)
                  .!error js/console "|[mermaid] render failed" error
```

## Verification

本次修复后的验证信号：

- `cr js` 编译通过，生成的 `js-out/app.comp.container.mjs` 中，`*rendered-svgs` 初始化为 `$clt._$n__$M_(_t_["_init_"], true)`，不再是 `$clt._$M_`。
- 浏览器控制台没有新的 `Uncaught (in promise)`。
- 控制台出现 `[mermaid] render` 调试日志。
- 执行 `document.querySelector(".mermaid-output").innerHTML` 时，返回内容以 `<svg` 开头，长度约 14k。

## Operational Checklist

以后 Mermaid 再出问题时，按这个顺序查：

1. 看 `.mermaid-output` 是否还有虚拟 DOM children。
2. 看缓存 atom 初始值是不是裸 `{}`。
3. 看 `:rendering` 锁是不是在 `ensure-mermaid!` 和 `render` 之前写入。
4. 看控制台是否有 `[mermaid] skip rendered`、`[mermaid] render`、`[mermaid] render failed`。
5. 直接检查 `.mermaid-output.innerHTML` 是否已经是 `<svg...`。

## Consequences

- `*rendered-svgs` 会永久带一个 `:_init_` 占位键，但不会影响按 source 查值。
- Mermaid 容器的占位内容现在统一走 `:innerHTML`，后续如果要加 loading/error UI，需要继续沿这个方向实现，而不是把文本 child 再塞回去。
- 这份 RFC 应该作为后续 Mermaid、Respo 命令式渲染和 Calcit atom 初始化问题的优先参考。
