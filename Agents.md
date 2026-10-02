Developer runs `calcit` for JavaScript build, and `yarn vite` to start the local server. LLMs should edit code through `calcit` commands, then trigger recompilation.

## 开工前必须看

先读通用 Calcit Agent 指南：

```bash
calcit docs agents --full
```

再看 Respo 模块用法：

```bash
calcit docs read Respo-Agent.md --full --module respo.calcit
```

## 高频命令

优先用查询命令定位，再做最小修改：

```bash
calcit query config
```

## 浏览器验证命令

前端联调时，优先使用 `chrome-devtools` 启动隔离浏览器，不要混用日常浏览器 profile。

常用命令：

```bash
chrome-devtools status
chrome-devtools start                       # headless 无界面模式（默认）
chrome-devtools start --headless false      # 界面模式，方便用户直接确认页面状态
chrome-devtools list_pages
chrome-devtools new_page 'http://127.0.0.1:3010'
chrome-devtools select_page <pageId> --bringToFront
chrome-devtools take_snapshot
chrome-devtools list_console_messages
chrome-devtools evaluate_script '() => document.body.innerText'
chrome-devtools click <uid>
chrome-devtools fill <uid> 'value'
```

推荐工作流：

- 先 `chrome-devtools status`，确认 daemon 已启动；需要时用 `chrome-devtools start --headless false` 以界面模式重启，方便用户直接看到浏览器窗口确认。
- 用 `new_page` 打开本地页面，再用 `list_pages` / `select_page` 切换目标页。
- 优先 `take_snapshot` 查看 a11y 树文本和元素 uid；只有需要看视觉细节时再截图。
- 先看 `list_console_messages`，再决定是否需要 `evaluate_script`、`click`、`fill`。
- 验证 websocket 或 `genui` 链路时，页面打开后先确认快照里出现 `Relay status: ready`，再从命令行发送请求。

```bash
calcit query ns <ns>
calcit query defs <ns>
calcit query def <ns/def>
calcit query search '<keyword>' --filter '<ns/def>'
calcit tree show <ns/def> --path '<path>'

```

高频修改命令：

```bash
calcit tree replace <ns/def> --path '<path>' --input-format cirru --code 'quote <code>'
calcit tree search-replace <ns/def> --pattern '<old>' --input-format cirru --code 'quote <new>'
calcit edit def <ns/def>
calcit edit add-import <ns> --input-format cirru --code 'quote $ src.ns :refer $ symbol'
```

高频验证命令：

```bash
calcit
yarn vite
```

relay 联调命令（端口 9100，系统 9001/9002 被 macOS 占用）：

```bash
edn-relay serve --bind 127.0.0.1:9100
edn-relay send --server ws://127.0.0.1:9100 --channel genui "$(cat /tmp/layout.cirru)" --timeout-secs 10
```

布局文件用 2 空格缩进（不要用 tab），示例：

```
{}
  :type |card
  :text "|Hello"
  :children $ []
    {} (:type |text) (:text "|world")
```

## 高频工作流

- 先定位再修改。先 `query def/search`，再 `tree show`，最后做 `tree replace` 或 `edit def`。
- 优先局部替换。不要整段重写 `calcit.cirru`，只改目标节点或小段结构。
- UI 改动和逻辑改动分开做，减少一次修改的影响面。
- 复杂结构先自检。尤其是 `let`、属性 map、嵌套列表、事件处理函数。
- 复用已有组件和样式。优先扩展现有 `defstyle`、组件和数据流，不重复造轮子。
- 每次改完都重新编译。默认先跑 `calcit`，需要看界面再跑 `yarn vite`。

## 高频踩坑

- `let` 只保留最后一个表达式。多个表达式要包一层 `div` 或 `do`。
- 属性 map 必须成对。不要把 `:style`、`:inner-text` 等属性写进同一个 pair。
- `keys` 返回 set，不是 list。拼接前先 `.to-list`。
- 不要用 `.to-map` 处理 list of pairs，改用 `pairs-map`。
- 避免生成“可调用字符串”。错误写法如 `(<> ((str ...)))`，正确写法是 `<> $ str ...`。
- 变量必须保持 leaf。像 `week-start` 这种变量不要变成单元素 list，否则会被当成调用。
- Respo 样式里的纯数字会自动补 `px`。`flex`、`font-weight`、`line-height`、`z-index` 这类属性要显式写字符串，例如 `:flex "\"1"`。
- Calcit 0.27 可直接用空 map `{}`；不要为旧编译器问题添加 `:_init_` 占位字段。`get` / `get-in` / `first` 返回 `Option`，必须显式处理缺失分支。
- Respo 和命令式 DOM 更新会互相打架。像 Mermaid 这种库如果直接写 `innerHTML`/SVG，不要再给同一个容器挂虚拟 DOM children；优先只保留 `:innerHTML` prop。
- Mermaid 的 `render` 需要并发保护。同一份 source 在一次渲染未完成前，要先写入 `:rendering` 之类的锁状态，避免重复调用同一个 graph id/source。

## 修改约束

- 严禁直接手改 `calcit.cirru`，必须使用 `calcit tree` 或 `calcit edit`。
- 路径不要猜。先用 `calcit query search` 拿路径，再用 `calcit tree show` 确认。
- 静态样式优先抽到 `defstyle`，动态列表中尽量少写内联 `:style`。
- `SKILL.md` 属于对外暴露文档；如果需要在页面运行时提供 `skill`，应通过 macro 把文本加载进 renderer，而不是让外部直接读仓库文件。
- 组件说明要用可检索的数据结构维护，方便 renderer 按名称或批量返回组件帮助。
- 面向 CLI 的帮助信息优先通过 renderer 协议暴露；实现细节不要堆回 `SKILL.md`。

## Mermaid/异步渲染补充约定

- 维护 Mermaid 节点时，优先检查三个面：Respo diff 是否会清空 DOM、缓存 atom 是否真的是 map、`render` 是否被重复触发。
- `comp-mermaid-block` 当前约定是：`.mermaid-output` 只承载 `:innerHTML`，不再放 placeholder 子节点；占位文案也通过 `:innerHTML` 切换。
- `render-mermaid-on` 当前约定是：先写缓存状态，再 `ensure-mermaid!`，再 `await mermaid.render(...)`，失败时写 `MermaidCache :failed`，成功时写 `MermaidCache :ready svg`。
- 浏览器联调时，先看 `chrome-devtools list_console_messages`，再查 `.mermaid-output.innerHTML` 是否真的变成 `<svg...`，不要只看页面上有没有文字变化。
