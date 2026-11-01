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

### 0.32.1 迁移：使用者影响与部署

CLI 与 `@calcit/procs` 需配对正式 **0.32.1**，模块固定已发布 Alerts **0.11.0**、Reel **0.7.0**、UI **0.9.0**、Respo **0.17.1**、JS FFI **0.2.9**；UI 自身固定的 Router alpha 传递依赖保留。升级后重新安装完整图、生成 JS 并刷新，不混用旧 runtime 或 main/hash。`calcit.cirru` 是源码，`js-out/` / `dist/` 不提交。

本次迁移不改 relay 协议、布局 DSL、旧存档格式或后端报告存储路径。Help 的 Alert `.show` 使用现有 API 要求的 `Option :none`；History、Library、Help 回调声明实际 Enum dispatcher 并返回 Unit。原 `hud!` 页面报错行为保留，不改为 raise。

`get-in` 返回 Result：必需的内部状态路径缺失时仍报错；存储响应中的可选 pending 路径失败时转为 Option none，继续忽略不匹配/过期响应。`*reel` 声明真实 `Ref<Map<Tag,Dynamic>>`，MathML namespace 声明 String，不用伪泛型或强转掩盖开放数据边界。原 `%some` JS 测试构造改为具名 Option，缓存、hydration、频道与 workspace 的原断言保持。

仍保留既有受检 Map updater 与三处真实 JS 宿主边界，不宣称 Dynamic 清零；历史依据见 [Reel #75](https://github.com/Respo/reel.calcit/issues/75) 和 [Calcit #2326](https://github.com/calcit-lang/calcit/issues/2326)。派生 LayoutNode 仍从原 DSL 重新校验构造，避免把 EDN 恢复的同名 Enum 当成具有本地声明身份的值。启动仍先成功恢复存档，再渲染及注册保存；恢复失败时保留原文。

原 canonical、all-defs、公开 namespace、完整 strict、deprecated 与频道缓存门禁保持。端到端 relay / MathML / 混合布局及 Save / Library 的本轮验收范围见 [TESTING.md](TESTING.md) 与 PR，不用历史通过项替代本轮证据，不增加 runner 或放宽断言。Vite 原有大 chunk 提示保留，不把构建成功当作性能验收。

`yarn build` 编译并打包前端，本地默认使用相对资源路径；生产构建指定：

```bash
VITE_BASE_URL=https://cos-sh.tiye.me/Erigeron/edn-renderer/ yarn build
```

前端 COS 仅上传 `dist/`，使用 `cos-upload-action@v1.2.0` 的 `public-base-url` 内置逐文件公开校验，不增加上传探针。需要原 `COS_BUCKET`、`COS_SECRET_ID`、`COS_SECRET_KEY` 和 `rsync_private_key`，服务器路径不变。PR 只检查、构建并保存相对资源 artifact，不上传 COS；生产使用原绝对 CDN 路径。

生产任务串行排队，上传前检查 main HEAD，跳过过期任务；通过后依次完成 COS 与原服务器同步，不中途取消。两个目标不保证原子发布，失败时按原流程排查。迁移本身不合并或部署业务应用，也不更新 relay 服务。

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
