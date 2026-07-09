# RFC: edn-renderer 的表单状态、事件与数据转换(草稿)

## 状态

Draft

## 背景

`edn-renderer` 目前是一个**纯展示型**的 DSL 渲染器：`LayoutNode`（一个
`defenum`，包含 `:column` `:row` `:card` `:text` `:badge` `:divider` `:button`
`:input` `:markdown` `:mermaid` `:chart` `:math`）由 `comp-layout-node` 只读渲染。
`button` 目前写死 `:disabled true`，`input` 没有接 `on-input`——CLI 可以下发
布局并检查/局部修改（`patch`/`replace`），但页面本身从不把用户交互回传出去。

我们想让 `edn-renderer` 支持简单的**表单**：字段持有本地状态，一个提交动作把
收集到的值回传给 CLI，部分字段还能由其他字段派生/格式化得到。

本 RFC 只覆盖设计，以下范围已经确定：

- 回传 CLI 的时机是**只在提交时回传一次**（不做逐字符的事件流量）。
- 数据转换覆盖**派生/计算字段**和**展示前的格式化**，不是自由脚本能力。
- 新增表单控件：`select`、`checkbox`、`radio`、`textarea`（在已有的 `input`
  之外）。

## 目标

- 字段在布局停留期间持有本地、可编辑的状态。
- 一个 `submit` 式动作把所有字段值收集成一个 map，通过 relay 回传给 CLI。
- 部分字段能用一棵**安全、白名单化**的表达式树从其他字段计算得到（派生值、
  格式化展示），绝不使用 `eval`。
- 扩展要贴合现有架构（`defenum` + `match` 渲染、`*reel`/`dispatch!`/`updater`
  reducer、relay 请求/响应协议），不引入新范式。

## 非目标

- 逐字符（每次按键）实时回传给 CLI。
- DSL 内的任意代码执行/脚本能力（安全边界，见下文）。
- 字段级校验的完整交互体验（错误态样式、异步校验器）——本 RFC 只包含
  必填/格式校验需要的最小挂钩，完整校验体验留给后续 RFC。

## 设计

### 1. LayoutNode 枚举扩展

在 `LayoutNode` 这个 `defenum`
（[app.comp.container/LayoutNode](../js-out/app.comp.container.mjs)）上新增
以下分支（其余既有分支不变）：

```cirru
defenum LayoutNode
  :select :string :list :string
  :checkbox :string :string :bool
  :radio :string :list :string
  :textarea :string :string :string
  :form :list :string
  :computed :dynamic :string
```

每个分支的字段含义：

| 分支 | 字段 1 | 字段 2 | 字段 3 |
|------|--------|--------|--------|
| `:select` | `name`（字段名） | `options`（选项列表） | `value`（当前值） |
| `:checkbox` | `name` | `label`（勾选框文案） | `checked`（是否勾选） |
| `:radio` | `name` | `options` | `value` |
| `:textarea` | `name` | `placeholder` | `value` |
| `:form` | `children`（子字段节点） | `submit-label`（提交按钮文案） | — |
| `:computed` | `transform`（转换树，见 §4） | `format`（展示格式化模板） | — |

- `select`/`radio` 的 `options` 是一组 `{} (:label ..) (:value ..)` 形式的 map（跟
  `chart` 的 `:series` 用同一套约定），例如：

  ```cirru
  {}
    :type |select
    :name |city
    :options $ []
      {} (:label |北京) (:value |bj)
      {} (:label |上海) (:value |sh)
    :value |bj
  ```

- `input`/`textarea` 接上真正的双向绑定：输入时触发 `on-input`，改为
  `dispatch!` 一个 `:form-field-changed` op，而不是纯装饰。
- `button` 新增可选的 `:action` 字段。`:action :submit` 让它触发提交流程，
  而不是渲染成 `:disabled true`。
- `form` 是新增的容器（和 `card`类似），子节点是各个字段；它决定提交时收集
  哪些字段（见下文），并渲染提交按钮。
- `computed` 渲染只读的派生文本，同时覆盖"派生字段"和"展示前格式化"这两个
  已确认的使用场景。

所有新增分支都走既有的校验路径：`parse-layout-node`/`validate-layout-node`，
格式不对时和现在一样快速失败。

### 2. 状态模型

在 `*reel` 的 `:renderer` 下新增一个 `:form-state` map
（[app.updater/updater](../js-out/app.updater.mjs)），以字段的 `:name` 为
key：

```cirru
{}
  :price 12
  :qty 3
  :agree true
```

`updater` 里新增的 reducer 分支，沿用现有的 `update store :renderer (fn
(renderer) ...)` 模式（和 `:relay-status`、`:select-history` 等现有分支
一致）：

```cirru
tag-match op
  (:form-field-changed name value)
    update store :renderer $ fn (renderer)
      assoc-in (or renderer {}) ([] :form-state name) value
  (:form-reset)
    update store :renderer $ fn (renderer)
      assoc (or renderer {}) :form-state $ {}
```

字段初始值来自 DSL 里各字段节点自身的 `:value`/`:checked`（这样 CLI 下发
布局时可以预填表单），缺省则为空字符串/`false`。

### 3. 事件流程

- **本地编辑**（打字、切换 checkbox、选 select 选项）：纯本地 `dispatch!`，
  更新 `:form-state`，不产生 relay 流量——符合"只在提交时回传一次"的
  决定。
- **提交**：点击 `form` 内、`:action :submit` 的 `button` 时：
  1. 读取当前 `:form-state`（只取这个 `form` 子树下声明过的字段名——用
     和 `layout-node-at-path`/`summarize-layout-node` 一样的方式遍历子树）。
  2. 计算这个 form 内所有 `computed` 字段，补全派生值。
  3. 通过既有的 `send-relay-frame!`（和 `send-genui-ack!` 走同一条发送
     路径）发送一个新的 relay 事件帧，例如：

     ```cirru
     {}
       :kind :event
       :channel selected
       :payload $ {}
         :op :form-submitted
         :layout_id $ :layout-id renderer
         :data $ {}
           :price 12
           :qty 3
           :full-name "|Jane Doe"
     ```

  4. 同时本地 `dispatch!` 一个 `:form-submitted` op，让页面能展示"已提交"
     的确认状态（纯 UI 反馈）。

  待确认问题：需要对照 `edn-relay` 的文档/`help` 确认，一个不挂在某个入站
  `request-id` 上的 `:kind :event` 帧，relay 是否已经会广播给 CLI 侧订阅了
  该 channel 的一方，还是需要给 relay 补一个"renderer 主动推送帧"的小能力。
  本 RFC 先假设协议里已有的按 channel 广播语义可以直接复用。

### 4. 数据转换（安全的表达式树）

因为 DSL payload 来自不受信任的远端 CLI，转换能力必须保持**声明式、
白名单化**——绝不把 DSL 里的字符串当 JS/Calcit 代码 `eval`（见"安全考虑"）。

沿用这个项目已有的建模方式——`LayoutNode` 本身就是一个 `defenum`——转换树
也建成一个 `Transform` `defenum`，而不是靠字符串 tag 拼出来的临时 map：

```cirru
defenum Transform
  :field :string
  :const :dynamic
  :add :list
  :sub :list
  :mul :list
  :div :list
  :concat :list
  :format :string :list
  :round :list
  :default :list
  :if :list
```

`:add`/`:sub`/`:mul`/`:div`/`:concat`/`:round`/`:default`/`:if` 的字段都是
`:list`，装的是嵌套的子 `Transform`；`:format` 除了子 `Transform` 列表，还带
一个模板字符串。

初始白名单覆盖"派生/计算字段"和"展示前格式化"这两个场景：

| 变体 | 参数 | 用途 |
|------|------|------|
| `:field` | 字段名 | 读取 `:form-state` 里的一个字段 |
| `:const` | 字面量 | 常量值 |
| `:add` `:sub` `:mul` `:div` | 2 个数值子转换 | 数值字段间的算术 |
| `:concat` | N 个字符串子转换 | 拼接文本（比如拼出全名） |
| `:format` | 模板字符串 + N 个子转换 | `"|{0} - {1}"` 这类插值展示 |
| `:round` | 1 个数值子转换 + 精度 | 数字展示格式化 |
| `:default` | 1 个子转换 + 兜底值 | 处理空字段 |
| `:if` | 3 个子转换（条件/then/else） | 简单的条件展示 |

DSL 线上格式（CLI 下发的 EDN，还没解析成 `Transform` 枚举前）继续沿用整个
项目通用的"map + tag 字段"约定，用 `:kind` 标注转换节点类型（避免跟
`LayoutNode` 的 `:type` 混淆）：

```cirru
{}
  :kind |add
  :args $ []
    {} (:kind |field) (:name |price)
    {} (:kind |field) (:name |qty)
```

新增一个 `eval-transform` 函数（放在 `app.comp.container`，或者新开一个
`app.transform` 命名空间），对解析后的 `Transform` 值做 `match`，从
`:form-state` 里查字段值。不做"按字符串动态派发到任意函数"，白名单就是这个
封闭的 `match`。

`computed` 布局节点携带一棵转换树 + 可选的 `:format`（比如
`"|¥{value}"`），在渲染成文本之前应用在最终的标量结果上。

### 5. Relay 协议触点

- `handle-genui-event!`/`handle-renderer-event!` 的请求侧不需要改动——布局
  仍然是 CLI → renderer 单向下发。
- 新增：renderer → CLI 的提交推送（`:op :form-submitted`，见 §3）。这是
  唯一新增的协议面，其余都是内部状态。

## 安全考虑

- **不对远端字符串做 `eval`。** 转换树是封闭词表的数据，由一个白名单化的
  Calcit 函数解释执行，而不是从 DSL 里读出来的 JS 源码或 Calcit 代码。这样
  可以避免通过精心构造的布局 payload 触发远程代码执行（对应 OWASP Top 10
  里 A03/A08 这类风险）。
- **限制转换树的深度/规模。** `eval-transform` 应该拒绝超过一定深度/参数
  个数的树，避免病态或超大 payload 导致过度递归（基础的资源耗尽防护），和
  现有 `validate-layout` 的快速失败行为保持一致。
- **表单数据只包含 DSL 声明过的内容。** 提交 payload 只由 `form` 子树里
  声明过的字段名构成，不是把 renderer/app 内部状态原样导出。

## 实施计划

1. 扩展 `LayoutNode` 这个 `defenum` + `parse-layout-node`/
   `validate-layout-node`，支持 `select`、`checkbox`、`radio`、`textarea`、
   `form`、`computed`。先做只读渲染，验证 DSL 形状端到端可用，暂不接状态。
2. 在 `*reel` 里加 `:form-state`，在 `updater` 里加
   `:form-field-changed`/`:form-reset` op，给 `input`/`textarea`/`select`/
   `checkbox`/`radio` 接上 `on-input`/`on-change` 派发这些 op。
3. 新增 `Transform` `defenum` + `eval-transform` 白名单解释器，实现
   `computed` 节点的渲染。
4. 让 `form` 内 `:action :submit` 的 `button` 收集该子树的表单状态、跑一遍
   `computed` 字段、发送 `:form-submitted` relay 事件；再加一个本地
   `:form-submitted` op 用于 UI 上的确认状态。
5. 更新 [COMPONENTS.md](../COMPONENTS.md) 和 [SKILL.md](../SKILL.md)，补上
   新节点类型、转换算子表、`form-submitted` 事件的形状——这些文档本身就是
   通过 `edn-relay help`/`skill` 实时暴露出去的。
6. 在 [test/](../test/) 下补 fixture：字段状态回环、提交 payload 形状、
   转换白名单求值（包括故意用一个不在白名单里的算子/超大转换树，验证会被
   拒绝）。

## 待确认问题

- 和 `edn-relay` 对一下 renderer → CLI 的主动推送帧协议（见 §3）。
- 是否需要在提交前就把字段级必填/格式校验展示出来（而不是只靠 CLI 拒绝
  不合法的 `:form-submitted` 数据）？本 RFC 先不做，标记为大概率的
  后续跟进项。
