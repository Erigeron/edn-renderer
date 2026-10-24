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
corepack enable && corepack prepare yarn@4.18.0 --activate
caps --strict --ci
yarn install --immutable

calcit
yarn vite --host 127.0.0.1 --port 3010
```

Published bootstrap page:

- `https://r.tiye.me/Erigeron/edn-renderer/`
- supports `?channel=<NAME>` to preselect a channel
- supports `?server=<WS_URL>` or `?port=<PORT>` to override the relay websocket target

If Vite fails because `rolldown` native bindings are missing, run `yarn install`
again so the unplugged package is materialized on disk.

### 前端构建与部署

使用配对的正式 Calcit / `@calcit/procs` 0.30.1，前端 Calcit 模块使用正式 tag；`calcit.cirru` 是源码，`js-out/` 仅在构建时生成，不提交。升级后重启开发服务并刷新页面，不混用旧runtime或模块缓存。
迁移将旧 Map 读取改为公开 Option API，保留原有 nil/default 语义；DOM/effect 和文本字段在真实边界检查类型，无效输入可能更早报错。
正式依赖为 Alerts 0.10.57、Reel 0.6.41、UI 0.8.0、Respo 0.16.124、JS-FFI 0.2.5（传递 Router 0.8.37）。legacy updater 回调在唯一入口检查 store、op-id、op-time，再调用原业务 updater，热重载返回值也经过 Map 解码，不以强转或放宽签名通过检查。见上游 [Reel #75](https://github.com/Respo/reel.calcit/issues/75)。

集合调用继续迁为当前公开方法：20 处 `.len`、6 处 `.foldl`、9 处 `.merge`，保留原参数、累积顺序、覆盖顺序及 Unicode 字符计数。原缓存回归中的 JS Set 计数也使用公开 `.len()`，不新增检查脚本。

MathML、Mermaid 模块和 ECharts 实例改用实际宿主成员检查，传给 DOM/图表的普通 JS 对象经过现有 `contract/expect-object`；非法宿主对象可能更早报错。13 处不受检查的强转被移除，仍保留 3 处真实外部合同：两处 ECharts `getInstanceByDom` 可空 JS 对象返回，以及含可选 `bindFunctions` 的 Mermaid 异步结果。它们不作为 nominal/payload 已验证的证据；具体图表实例另经 `js-cast` 检查。模块对象导入用法的限制见上游 [Calcit #2326](https://github.com/calcit-lang/calcit/issues/2326)。不改变 relay 协议、存档格式、Mermaid 渲染锁/失败缓存或 `hud!` 行为；依赖版本与生产部署路径不变。

启动时先恢复`workflow`存档，再渲染及注册保存回调；恢复失败时保留原始值供排查，不用默认状态覆盖。MathML子节点由现有`list?`分支证明后直接使用，不再重复断言；真实DOM/图表/Promise边界仍显式保留，页面热更新继续使用`hud!`。

布局预览由断言改为真实解码。Cirru EDN 恢复的派生 Enum 不保留声明身份，因此 hydration、频道缓存和 current workspace 恢复从保存的原始 DSL 重新校验、构造 LayoutNode；保留旧存档格式和缺失布局的 nil 语义，无效数据可能更早报错。21 处冗余 `do` 包装已删除，执行顺序不变。12 处兼容调用迁为当前公开 `match`、`Option :some/:none` 和 `remove-watch!`，保留原字面量分支、默认值和 watcher 行为；deprecated calls 已清零。

本地完整 strict、公开定义 108/108、原 channel-cache/relay snapshot、混合布局和 MathML 回归通过；Save、Library 合成报告加载、current workspace 切换及 patch 后刷新恢复均已实测。新增回归直接放入原缓存脚本，不另造脚本或预算。CI 增加现有 full strict 门禁；开放 DSL/FFI 类型边界仍如实记录，不宣称零债务。状态更新仍使用 `update-state-tree`，relay 协议和报告存储路径不变。
`yarn build` 编译 Calcit 并打包前端。本地默认使用相对资源路径；生产构建指定：

```bash
VITE_BASE_URL=https://cos-sh.tiye.me/Erigeron/edn-renderer/ yarn build
```

工作流只在主分支推送时部署：先上传 `dist/` 至 COS，由 `cos-upload-action` 的 `public-base-url` 启用内置校验，成功后再将入口页等构建文件同步至原服务器目录。需要配置 `COS_BUCKET`、`COS_SECRET_ID`、`COS_SECRET_KEY`，原 `rsync_private_key` 和服务器路径保持不变。PR只构建、不上传，保留同次相对资源路径构建artifact用于本地验收；生产仍用原绝对CDN路径。

生产任务串行排队；开始上传前检查当前 main，跳过已过期的任务。通过检查的任务依次完成 COS 上传和服务器同步，不在中途重复检查 main。两个目标并非原子发布；服务器同步失败时须检查并重跑部署。此迁移不改动 relay 服务或报告存储路径。

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
calcit
```

For a dedicated renderer, CLI, and browser validation checklist, see [TESTING.md](TESTING.md).

For isolated browser validation, use the `chrome-devtools` workflow described in
[Agents.md](Agents.md).

## License

MIT
