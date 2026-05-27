# `edn-renderer` Skill

这是一份给其他项目复用的操作手册，目标是统一 `edn-relay` + `edn-renderer` 这一套 CLI 到浏览器的工作流。

这份文档不只是在描述当前项目怎么跑，也在明确一组应该长期保持稳定的使用约定，方便别的项目直接引用。

---

## 1. 目标

`edn-renderer` 的角色，是把 Cirru EDN 布局 payload 渲染到浏览器里，并把运行时结果、文档能力、调试信息暴露给 CLI。

典型循环是：

1. 启动 relay
2. 启动 renderer 页面
3. 用 CLI 向当前 renderer 发送 payload
4. 在浏览器里看渲染结果
5. 在 CLI 里查询帮助、技能文档、组件说明

---

## 2. 统一约定

这份 skill 采用下面这些约定，后续其他项目也建议遵守：

### 2.1 relay CLI 默认无状态

当前约定是：

- relay 服务默认监听 `127.0.0.1:9100`
- 请求类命令默认连接 `ws://127.0.0.1:9100`
- 如果 relay 不在默认地址，命令上显式传 `--server ...`
- channel 始终由每次命令上的 `--channel ...` 指定

也就是说，使用时优先是这种形式：

- `edn-relay serve`
- `edn-relay channels`
- `edn-relay send --channel genui '<LAYOUT>'`
- `edn-relay help --channel genui`
- `edn-relay skill --channel genui`
- `edn-relay status --channel genui`
- `edn-relay open --channel genui`

只有 relay 地址不是默认值时，才补充：

- `--server ws://127.0.0.1:xxxx`
- 或 `serve --bind 127.0.0.1:xxxx`

### 2.2 channel 显式指定，不维护当前上下文

relay CLI 不维护“当前 renderer / 当前 channel / 最近一次上下文”这类持久化状态。

用户体验应该依赖：

- 默认 relay 地址
- 每次命令显式的 `--channel`
- `edn-relay channels` 查看当前有哪些 receiver 已建立 channel
- `edn-relay open --channel ...` 在已连接的 renderer 页面之间快速打开目标 receiver

### 2.3 文档通过协议查询，不靠手工记忆

具体业务能力，不应该靠用户记命令细节，而应该通过：

- `edn-relay help --channel <name>`

让 relay 按协议向目标 channel 上的 renderer 查询文档，再决定怎么使用。

也就是说：

1. 先运行 `edn-relay help --channel <name>`
2. 由 relay 从 renderer 侧拉取可用文档
3. 再根据返回的文档去发 payload 或查询具体组件

这样做的好处是：

- CLI 和 renderer 的能力不会脱节
- renderer 新增组件后，CLI 能自动发现
- 其他项目接入时，不需要额外抄一份命令说明

### 2.4 skill 也要通过 renderer 暴露

`SKILL.md` 不应只是仓库里的静态说明文件。

约定上，renderer 应该在运行时把这份 skill 暴露给：

- `edn-relay skill --channel <name>`

也就是说，后续的使用习惯应该是：

1. `edn-relay skill --channel <name>`
2. relay 从目标 channel 上的 renderer 拿到 skill 内容
3. CLI 侧展示或检索 skill

这样其他项目不必直接读取仓库文件，也能通过运行中的 renderer 获取最新 skill。

默认 `edn-relay skill --channel <name>` 更适合返回简短工作流总览；如果要某一类技能，再追加 topic，例如：

- `edn-relay skill --channel genui workflow`
- `edn-relay skill --channel genui math`
- `edn-relay skill --channel genui validation`
- `edn-relay skill --channel genui full`

### 2.5 组件说明要支持检索

组件文档不要只写成一长段不可检索的文本。

更推荐的约定是：

- 支持按名称查询
- 支持显式列出全部组件
- 支持同时返回参数、说明、示例

例如概念上，应该能支持这类查询：

- 查询全部组件，比如 `edn-relay help --channel genui components`
- 查询单个组件，比如 `chart`、`mermaid`、`math`
- 批量查询多个组件，比如 `chart`、`mermaid`、`markdown`

这样 `edn-relay help --channel <name>` 才能真正成为一个可检索接口，而不只是打印一段静态帮助。

### 2.6 渐进披露优先

默认帮助不应该一次返回所有组件细节和全部案例。

更推荐的顺序是：

1. `edn-relay help --channel <name>` 先看总览
2. `edn-relay help --channel <name> components` 或 `math` 再看具体组件
3. `edn-relay help --channel <name> examples` 或 `math-fraction-demo` 再看案例
4. 最后再运行 `edn-relay send --channel <name> ...`

这样可以避免 CLI 一上来就把全部配置细节、组件说明和案例一起打印出来。

---

## 3. 推荐使用方式

### 3.1 启动 relay

约定上，CLI 层应该尽量简化成：

```bash
edn-relay serve
```

是否监听本地某个端口、如何绑定、如何记住状态，都应该由 relay 内部处理，而不是由用户每次手工指定。

### 3.2 启动 renderer

在 renderer 项目里，开发时仍然需要把页面跑起来。

典型本地命令仍然是：

```bash
cr js
yarn vite
```

这里不强调具体端口号，重点是：

- renderer 页面能打开
- renderer 能连接目标 relay
- renderer 能通过协议提供文档、skill、组件说明和渲染能力

### 3.3 打开浏览器页面

推荐继续使用隔离浏览器和 `chrome-devtools`：

```bash
chrome-devtools status
chrome-devtools start --headless false
chrome-devtools new_page '<renderer page url>'
chrome-devtools take_snapshot
chrome-devtools list_console_messages
```

这里的页面地址属于开发环境细节，不应该成为 CLI 使用者每次都要记住的协议参数。

---

## 4. 用 CLI 试用 renderer 的方式

### 4.1 最小发送方式

面向使用者时，更推荐展示这种形式：

```bash
edn-relay send --channel genui '
{}
  :type |card
  :text "|CLI Demo"
  :children $ []
    {} (:type |badge) (:text |preview)
    {} (:type |divider)
    {} (:type |text) (:text "|Hello from CLI")
'
```

重点是：

- 默认情况下不需要反复出现 `--server`
- 不要求用户手动记 websocket 地址
- channel 由每次命令上的 `--channel` 显式决定

### 4.2 先问 help，再发业务 payload

推荐流程不是“先猜功能”，而是：

1. 运行 `edn-relay help --channel <name>`
2. 从 renderer 返回的文档里看当前支持什么
3. 再运行 `edn-relay send --channel <name> ...`

如果要查询 skill，则走：

1. 运行 `edn-relay skill --channel <name>`
2. 从 renderer 返回 skill 内容
3. 再根据 skill 决定怎么调试、怎么探索能力

如果只想看某一块技能，而不是整份操作手册，则优先：

1. `edn-relay skill --channel <name> workflow`
2. `edn-relay skill --channel <name> math`
3. 只有确实需要完整文档时再用 `edn-relay skill --channel <name> full`

如果要查看当前 renderer 页面状态，则可以：

1. 运行 `edn-relay status`
2. 查看当前 renderer 标题、页面地址和可用命令
3. 需要直接打开页面时再运行 `edn-relay open`

### 4.3 MathML 也走同样流程

如果要试 MathML Core，推荐顺序仍然是：

1. `edn-relay help --channel genui math`
2. `edn-relay help --channel genui math-fraction-demo`
3. 再发送最小公式 payload

例如：

```bash
edn-relay send --channel genui '
{}
  :type |math
  :display |block
  :expr $ [] |mfrac
    [] |mrow
      [] |mi |a
      [] |mo |+
      [] |mi |b
    [] |msqrt
      [] |mi |c
'
```

---

## 5. 如何发现 renderer 当前支持哪些功能

### 5.1 首选 `edn-relay help --channel <name>`

后续面向使用者的统一入口，应该是：

```bash
edn-relay help --channel genui
```

这条命令的职责应该是：

- 从目标 channel 上的 renderer 查询可用文档
- 默认只列出可用能力和下一步建议
- 提示支持的组件和业务入口
- 给出下一步可执行的命令建议

已经适合直接使用的形式包括：

- `edn-relay help --channel genui`
- `edn-relay help --channel genui components`
- `edn-relay help --channel genui protocol`
- `edn-relay help --channel genui examples`
- `edn-relay help --channel genui math`
- `edn-relay help --channel genui chart mermaid`
- `edn-relay help --channel genui card-demo`
- `edn-relay help --channel genui math-fraction-demo`

### 5.2 组件级帮助应该可检索

对于组件说明，renderer 侧应该提供可检索的组件帮助接口。

目前推荐按下面几类来查：

- 组件：例如 `chart`、`mermaid`、`math`
- 协议：例如 `protocol`
- 示例：例如 `examples`、`card-demo`、`math-fraction-demo`

比如概念上应该支持：

- 显式列出全部组件
- 查询指定组件的说明
- 批量查询多个组件
- 返回示例 payload

这类能力应该从 renderer 侧通过协议暴露出来，而不是让调用方直接读仓库源文件。

### 5.3 skill 作为更高层的操作指南

`edn-relay help --channel <name>` 偏向能力目录，并且应该默认保持简短。

`edn-relay skill --channel <name>` 偏向操作经验和工作流，也应该默认保持简短；完整手册只在显式请求 `full` 时返回。

两者的分工建议是：

- `help`：查“有哪些能力”
- `skill`：查“怎么用这套能力干活”

---

## 6. 在开发 renderer 本身时，仍然可以这样查实现

虽然面向使用者的推荐入口是 `edn-relay help --channel <name>` / `edn-relay skill --channel <name>`，但开发 renderer 自己时，仍然可以直接查代码。

推荐顺序：

1. `README.md`
2. `COMPONENTS.md`
3. `Agents.md`
4. `cr query` 直接查定义

例如：

```bash
cr query def app.comp.container/LayoutNode
cr query def app.comp.container/validate-layout-node
cr query def app.comp.container/comp-layout-node
cr query search 'mermaid'
cr query search 'chart'
cr query search 'genui'
```

这些命令适合开发者，不适合最终 CLI 使用者。最终 CLI 使用者更应该通过协议化 help 来发现功能。

---

## 7. 浏览器侧如何验证

虽然帮助和 skill 未来会从 renderer 协议暴露出来，但浏览器验证仍然很重要。

推荐命令：

```bash
chrome-devtools take_snapshot
chrome-devtools list_console_messages
chrome-devtools take_screenshot --fullPage --filePath artifacts/debug.png
```

经验上：

- `snapshot` 适合看结构和可访问树
- `screenshot` 适合看视觉结果
- `list_console_messages` 适合看图表、mermaid、overlay、事件问题

---

## 8. 常见问题排查思路

### 8.1 relay 侧问题

现象：

- renderer 显示未连接
- CLI 超时等不到 ack
- help / skill 查不出来内容

优先检查：

- relay 是否已启动
- `--server` 是否指向了正确的 relay
- renderer 是否成功连接目标 relay

### 8.2 文档 / skill 发现问题

如果 `edn-relay help --channel <name>` 或 `edn-relay skill --channel <name>` 没有返回预期内容，优先怀疑：

- renderer 侧没有把文档通过协议暴露出去
- skill 没有被 renderer 在运行时正确暴露
- 组件说明没有以可检索方式对外提供

### 8.3 chart 空白

这个项目已经验证过一个关键经验：

**图表库最终拿到的必须是原生 JS object，而不是原始 Calcit map。**

所以如果图表区域是空的，先查：

- 传给图表库的最终对象结构
- host 尺寸是不是正常
- 是否实际生成 canvas

### 8.4 drawer / modal 点不动

如果按钮表面上能点，但没反应，优先查是不是有透明 overlay 盖住了页面。

一个简单探针是检查按钮中心点真正命中的元素是不是按钮本身。

---

## 9. 在其他项目里怎么复用这份 skill

如果别的项目想复用 `edn-renderer` 这套能力，建议直接沿用下面的接口习惯：

1. `edn-relay serve` 启动 relay
2. `edn-relay channels` 查看当前有哪些 channel 已连上 receiver
3. `edn-relay status --channel <name>` 查询目标 renderer 状态
4. `edn-relay help --channel <name>` 查询目标 renderer 暴露的文档
5. `edn-relay skill --channel <name>` 查询目标 renderer 暴露的操作技能
6. `edn-relay send --channel <name> ...` 发送实际 payload
7. 浏览器里用 drawer 和 console 做细节验证

也就是说，别的项目最好复用的是：

- 默认 relay 地址 + 可选 `--server` 的无状态模型
- channel 显式指定的交互模型
- renderer 侧帮助文档 / skill 的协议暴露方式
- 组件文档的可检索暴露方式

---

## 10. 建议沉淀成长期接口的内容

为了方便长期复用，建议把下面这些能力稳定下来：

- `edn-relay serve`
- `edn-relay channels`
- `edn-relay status --channel <name>`
- `edn-relay open --channel <name>`
- `edn-relay help --channel <name>`
- `edn-relay skill --channel <name>`
- `edn-relay send --channel <name>`
- 默认 relay 地址 + 可选 `--server` 的连接约定
- renderer 侧的文档查询协议
- renderer 侧的 skill 查询协议
- 组件说明的可检索暴露结构

这样后续无论换项目还是换 renderer，只要遵守同一套约定，CLI 使用方式就能保持一致。

---

## 11. 在其他项目中的引用建议

你可以在其他项目里这样引用这份文档：

> 关于 `edn-relay` 与 `edn-renderer` 的统一 CLI / help / skill 工作流，请参考 `edn-renderer/SKILL.md`。
