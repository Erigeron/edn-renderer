# edn-renderer 组件文档

## 整体架构

本项目由两个部分组成：

- **edn-relay**：通用 WebSocket 中继服务器，负责消息路由和协议帧处理。relay 本身无业务逻辑，通过**频道名称**（如 `genui`）标识不同场景。
- **edn-renderer**：前端渲染器，保存 UI 上下文和组件能力。命令行通过 relay 向 renderer 发送布局描述（Layout DSL），renderer 解析后渲染对应的 UI 组件。

```
CLI / 脚本
  │  edn-relay send --channel genui '<layout>'
  ▼
edn-relay (relay)
  │  WebSocket 消息路由 (genui 频道)
  ▼
edn-renderer (browser)
  │  parse-layout-node → 渲染组件树
  ▼
页面 UI
```

**设计原则**：

- relay 保持通用，不感知业务
- renderer 维护所有 UI 能力（组件列表、状态管理）
- Layout 组件负责将原子组件组合成复杂界面
- 命令行可通过频道名称选择对应的 renderer 能力

---

## Layout DSL 格式

Layout 使用 Cirru EDN 格式描述，顶层为一个 map，包含 `:type` 字段标识节点类型。子节点通过 `:children` 列表组合。

```cirru
{}
  :type |column
  :children $ []
    {}
      :type |text
      :text "|Hello, World!"
    {}
      :type |chart
      :kind |bar
      :title "|Sales Data"
      :series $ []
        {} (:label |Q1) (:value 120)
        {} (:label |Q2) (:value 145)
```

---

## 布局容器

### column（垂直列）

子节点纵向排列。

```cirru
{}
  :type |column
  :children $ []
    {} (:type |text) (:text "|第一行")
    {} (:type |text) (:text "|第二行")
```

### row（水平行）

子节点横向排列。

```cirru
{}
  :type |row
  :children $ []
    {} (:type |badge) (:text "|标签A")
    {} (:type |badge) (:text "|标签B")
```

### card（卡片）

带标题的容器，`:text` 为卡片标题，`:children` 为内容。

```cirru
{}
  :type |card
  :text "|数据概览"
  :children $ []
    {} (:type |text) (:text "|内容在这里")
```

---

## 文本组件

### text（普通文本）

渲染一段文字，`:text` 为内容。

```cirru
{} (:type |text) (:text "|这是一段描述")
```

### badge（徽标）

带样式的标签，适合状态或分类标注。

```cirru
{} (:type |badge) (:text "|进行中")
```

### markdown（Markdown）

将 `:text` 内容渲染为 Markdown 富文本。

```cirru
{} (:type |markdown) (:text "|## 标题\n\n这是**粗体**文字。")
```

---

## 交互组件

### button（按钮）

显示一个按钮，当前为只读展示状态（`:disabled true`）。

```cirru
{} (:type |button) (:text "|点击操作")
```

### input（输入框）

显示文本输入框，`:name` 为标识，`:placeholder` 为提示文字，`:text` 为当前值。

```cirru
{}
  :type |input
  :name "|search"
  :placeholder "|搜索关键词"
  :text |
```

---

## 分隔线

### divider（分割线）

水平分隔线，无额外参数。

```cirru
{} (:type |divider)
```

---

## 图表组件

### chart（ECharts 图表）

使用 ECharts 渲染数据可视化图表。支持多种图表类型。

| 字段      | 类型   | 说明                                                                                          |
| --------- | ------ | --------------------------------------------------------------------------------------------- |
| `:kind`   | 字符串 | 图表类型：`bar`（柱状图）、`line`（折线图）、`pie`（饼图）、`scatter`（散点图）。默认 `bar`。 |
| `:title`  | 字符串 | 图表标题（可选）                                                                              |
| `:series` | 列表   | 数据项，每项包含 `:label`（字符串）和 `:value`（数字）                                        |

**柱状图示例**：

```cirru
{}
  :type |chart
  :kind |bar
  :title "|各区域销售额"
  :series $ []
    {} (:label |北区) (:value 42)
    {} (:label |南区) (:value 27)
    {} (:label |西区) (:value 35)
```

**折线图示例**：

```cirru
{}
  :type |chart
  :kind |line
  :title "|月度趋势"
  :series $ []
    {} (:label |1月) (:value 10)
    {} (:label |2月) (:value 18)
    {} (:label |3月) (:value 14)
    {} (:label |4月) (:value 22)
```

**饼图示例**：

```cirru
{}
  :type |chart
  :kind |pie
  :title "|市场份额"
  :series $ []
    {} (:label |产品A) (:value 55)
    {} (:label |产品B) (:value 25)
    {} (:label |产品C) (:value 20)
```

---

## 图表渲染机制

`comp-chart-block` 将图表配置（kind、title、series）序列化为 Cirru EDN 格式，存储在 DOM 节点的 `title` 属性中。`main.mjs` 通过 `MutationObserver` 监听 `.echarts-host` 节点的插入，解析数据后调用 `echarts.setOption()` 渲染。

这与 Mermaid 图表的渲染方式相同，保持了一致的「Calcit 写入属性 → JS 读取渲染」的分工模式。

---

## Mermaid 图表

### mermaid（流程图 / 时序图等）

使用 [Mermaid](https://mermaid.js.org/) 渲染图形，`:text` 为 Mermaid DSL 语法。

```cirru
{}
  :type |mermaid
  :text "|graph TD\n  A[开始] --> B{条件}\n  B -->|是| C[执行]\n  B -->|否| D[跳过]"
```

---

## 完整示例

```cirru
{}
  :type |column
  :children $ []
    {}
      :type |card
      :text "|销售看板"
      :children $ []
        {}
          :type |row
          :children $ []
            {} (:type |badge) (:text "|本季度")
            {} (:type |badge) (:text "|对比去年 +12%")
        {} (:type |divider)
        {}
          :type |chart
          :kind |bar
          :title "|各区域销售额（万元）"
          :series $ []
            {} (:label |华北) (:value 88)
            {} (:label |华东) (:value 120)
            {} (:label |华南) (:value 95)
            {} (:label |西部) (:value 62)
    {}
      :type |chart
      :kind |pie
      :title "|产品线占比"
      :series $ []
        {} (:label |硬件) (:value 45)
        {} (:label |软件) (:value 35)
        {} (:label |服务) (:value 20)
```

---

<!-- 以下为旧版英文文档存档，已由上方中文文档取代 -->

## Envelope Shape (legacy)

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

Mermaid diagram block rendered from source text.

Required fields:

- `:text`

Notes:

- the renderer turns the Mermaid source into an SVG diagram in the preview area
- diagram rendering is triggered automatically when relay updates insert or replace Mermaid nodes

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
