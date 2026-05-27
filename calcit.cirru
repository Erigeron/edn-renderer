
{} (:about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `cr query` to inspect and `cr edit`/`cr tree` to modify. Run `cr docs agents --full` first. Manual edits must follow format and schema conventions, then run `cr edit format`.") (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |respo.calcit/ |memof/ |respo-ui.calcit/ |reel.calcit/ |alerts.calcit/
  :entries $ {}
  :files $ {}
    |app.comp.container $ %{} :FileEntry
      :defs $ {}
        |*mermaid-ready $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote (defatom *mermaid-ready false)
          :examples $ []
        |*rendered-svgs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defatom *rendered-svgs $ {} (:_init_ true)
          :examples $ []
        |LayoutNode $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def LayoutNode $ defenum LayoutNode (:column :list) (:row :list) (:card :dynamic :list) (:text :string) (:badge :string) (:divider) (:button :string) (:input :dynamic :dynamic :dynamic) (:markdown :string) (:mermaid :string) (:chart :dynamic :dynamic :list)
          :examples $ []
        |build-echarts-option $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-echarts-option (series kind title)
              let
                  normalized-kind $ if (string? kind) kind |bar
                  normalized-series $ if (list? series) series ([])
                  names $ -> normalized-series .to-list
                    map $ fn (item) (:label item)
                  values $ -> normalized-series .to-list
                    map $ fn (item) (:value item)
                  title-part $ if
                    or (nil? title) (= title |)
                    {}
                    {} $ :title
                      {} $ :text title
                  base $ merge
                    {} (:animation false)
                      :tooltip $ {}
                    , title-part
                case-default normalized-kind
                  merge base $ {}
                    :xAxis $ {} (:type |category) (:data names)
                    :yAxis $ {} (:type |value)
                    :series $ []
                      {} (:type |bar) (:data values)
                  |line $ merge base
                    {}
                      :xAxis $ {} (:type |category) (:data names)
                      :yAxis $ {} (:type |value)
                      :series $ []
                        {} (:type |line) (:data values)
                  |pie $ merge base
                    {} $ :series
                      [] $ {} (:type |pie)
                        :data $ -> normalized-series .to-list
                          map $ fn (item)
                            {}
                              :name $ :label item
                              :value $ :value item
                  |scatter $ merge base
                    {}
                      :xAxis $ {} (:type |category) (:data names)
                      :yAxis $ {} (:type |value)
                      :series $ []
                        {} (:type |scatter) (:data values)
          :examples $ []
        |build-mermaid-render-payload $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-mermaid-render-payload (text)
              let
                  source $ if (string? text) text |
                  trimmed $ trim source
                if (= trimmed |)
                  {} (:empty? true) (:source |) (:graph-id |)
                  {} (:empty? false) (:source source)
                    :graph-id $ str |mermaid- (count source) |-
                      count $ split-lines source
          :examples $ []
        |comp-chart-block $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defcomp comp-chart-block (series kind title)
              let
                  option $ build-echarts-option series kind title
                [] (effect-echarts option)
                  div $ {} (:class-name |echarts-host)
                    :style $ {} (:width |100%) (:height |300px)
          :examples $ []
        |comp-container $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defcomp comp-container (reel)
              let
                  store $ :store reel
                  states $ :states store
                  relay $ or (:relay store) {}
                  renderer $ or (:renderer store) {}
                  drawer-open? $ get-in states ([] :drawer :data :show?)
                  selected-channel $ :selected-channel relay
                  channels $ if
                    list? $ :channels relay
                    :channels relay
                    []
                  drawer-plugin $ use-drawer (>> states :drawer)
                    {}
                      :style $ {} (:width 420) (:min-width 0) (:max-width "|calc(100vw - 20px)") (:padding "|14px 14px 18px") (:gap 14) (:background-color |#fffaf4) (:border-left "|1px solid #ead8c7") (:box-shadow "|-10px 0 30px hsla(24, 35%, 18%, 0.12)") (:overflow |auto)
                      :container-style $ if drawer-open?
                        {} (:position :fixed) (:top 0) (:right 0) (:bottom 0) (:left 0) (:z-index |40)
                        {}
                      :backdrop-style $ {} (:background-color "|hsla(28, 40%, 16%, 0.16)") (:backdrop-filter "|blur(10px)")
                      :render $ fn (on-close)
                        div
                          {} $ :style
                            {} (:display |flex) (:flex-direction |column) (:gap 14)
                          div
                            {} $ :style
                              {} (:display |flex) (:justify-content |space-between) (:align-items |flex-start) (:gap 12)
                            div
                              {} $ :style
                                {} (:display |flex) (:flex-direction |column) (:gap 6)
                              div
                                {} $ :style
                                  {} (:font-size 12) (:font-weight |700) (:letter-spacing |1px) (:text-transform |uppercase) (:color |#8b6244)
                                <> "|Live session"
                              div
                                {} $ :style
                                  {} (:font-size 22) (:font-weight |700) (:line-height |1.1) (:color |#2b2018)
                                <> "|Renderer diagnostics"
                              div
                                {} $ :style
                                  {} (:font-size 13) (:line-height |1.6) (:color |#7b6451)
                                <> "|Inspect relay status, request ids, available channels, and the exact Cirru EDN payload being rendered."
                            button $ {} (:class-name css/button) (:inner-text |Close)
                              :style $ {} (:padding "|8px 12px") (:align-self |flex-start)
                              :on-click $ fn (e d!) (on-close d!)
                          div
                            {} $ :style
                              {} (:display |flex) (:gap 10) (:flex-wrap |wrap)
                            div
                              {} $ :style
                                {} (:padding "|8px 12px") (:border-radius 999) (:background-color |#fff) (:border "|1px solid #ead8c7") (:font-size 13) (:color |#6b4a32)
                              <> $ str "|Relay: "
                                or (:status relay) |idle
                            if-let
                              request-id $ :last-request renderer
                              div
                                {} $ :style
                                  {} (:padding "|8px 12px") (:border-radius 999) (:background-color |#fff) (:border "|1px solid #ead8c7") (:font-size 13) (:color |#6b4a32)
                                <> $ str "|Request: " request-id
                            div
                              {} $ :style
                                {} (:padding "|8px 12px") (:border-radius 999) (:background-color |#fff) (:border "|1px solid #ead8c7") (:font-size 13) (:color |#6b4a32)
                              <> $ str "|Channels: " (count channels)
                          div
                            {} $ :style
                              {} (:display |flex) (:flex-direction |column) (:gap 8) (:padding 14) (:border-radius 18) (:background-color |#fff7ef) (:border "|1px solid #ead8c7")
                            div
                              {} $ :style
                                {} (:font-size 12) (:font-weight |700) (:letter-spacing |1px) (:text-transform |uppercase) (:color |#8b6244)
                              <> |Relay
                            div ({})
                              if (some? selected-channel)
                                <> $ str "|Selected channel: " selected-channel
                                <> "|No channel selected yet."
                            if
                              > (count channels) 0
                              list->
                                {} $ :style
                                  {} (:display |flex) (:gap 8) (:flex-wrap |wrap)
                                -> channels .to-list $ map-indexed
                                  fn (idx channel)
                                    [] idx $ div
                                      {} $ :style
                                        {} (:padding "|6px 10px") (:border-radius 999)
                                          :background-color $ if (= channel selected-channel) |#f3d7ba |#fff
                                          :border $ if (= channel selected-channel) "|1px solid #cf8b5d" "|1px solid #ead8c7"
                                          :font-size 12
                                          :color |#6b4a32
                                      <> channel
                            if-let
                              client-id $ :client-id relay
                              div ({})
                                <> $ str "|Client: " client-id
                            if-let
                              relay-error $ :last-error relay
                              div
                                {} $ :style
                                  {} (:font-size 13) (:line-height |1.5) (:color |#a23f1a)
                                <> $ str "|Relay error: " relay-error
                          div
                            {} $ :style
                              {} (:display |flex) (:flex-direction |column) (:gap 8) (:padding 14) (:border-radius 18) (:background-color |#fffdf9) (:border "|1px solid #ead8c7")
                            div
                              {} $ :style
                                {} (:font-size 12) (:font-weight |700) (:letter-spacing |1px) (:text-transform |uppercase) (:color |#8b6244)
                              <> "|Latest payload"
                            if-let
                              render-error $ :last-error renderer
                              div
                                {} $ :style
                                  {} (:font-size 13) (:line-height |1.5) (:color |#a23f1a)
                                <> $ str "|Validation error: " render-error
                            textarea $ {}
                              :value $ or (:layout-source renderer) |
                              :read-only true
                              :spell-check false
                              :placeholder "|Incoming Cirru EDN layout payload will appear here."
                              :style $ {} (:width |100%) (:min-height |280px) (:padding 12) (:box-sizing |border-box) (:border-radius 14) (:border "|1px solid #dcc8b6") (:background-color |#fff) (:font-family |Monaco) (:font-size 12) (:line-height |1.6) (:resize |vertical)
                          when dev? $ comp-reel (>> states :reel) reel ({})
                  help-alert $ use-alert (>> states :help)
                    {} $ :text "|Use the drawer to inspect relay status, request ids, channel state, and incoming Cirru EDN without reserving a permanent sidebar."
                div
                  {} $ :style
                    {} (:min-height |100vh) (:padding 20) (:box-sizing |border-box) (:background-color |#f6efe6) (:color |#2b2018) (:font-family |Avenir)
                  div
                    {} $ :style
                      {} (:display |flex) (:justify-content |space-between) (:align-items |center) (:gap 12) (:padding "|12px 14px") (:border-radius 20) (:background-color |#fffaf4) (:border "|1px solid #ead8c7") (:flex-wrap |wrap)
                    div
                      {} $ :style
                        {} (:display |flex) (:align-items |center) (:gap 10) (:flex-wrap |wrap)
                      div
                        {} $ :style
                          {} (:font-size 22) (:font-weight |700) (:line-height |1.1)
                        <> "|EDN Renderer"
                      div
                        {} $ :style
                          {} (:padding "|4px 10px") (:border-radius 999) (:background-color |#fff) (:border "|1px solid #ead8c7") (:font-size 12) (:color |#8b6244)
                        if (some? selected-channel)
                          <> $ str "|Channel: " selected-channel
                          <> "|Choose channel"
                    div
                      {} $ :style
                        {} (:display |flex) (:gap 8) (:flex-wrap |wrap) (:align-items |center) (:justify-content |flex-end)
                      div
                        {} $ :style
                          {} (:padding "|6px 10px") (:border-radius 999) (:background-color |#fff7ef) (:border "|1px solid #ead8c7") (:font-size 12) (:color |#6b4a32)
                        <> $ str "|Relay: "
                          or (:status relay) |idle
                      div
                        {} $ :style
                          {} (:padding "|6px 10px") (:border-radius 999) (:background-color |#fff7ef) (:border "|1px solid #ead8c7") (:font-size 12) (:color |#6b4a32)
                        if
                          some? $ :layout-id renderer
                          <> "|Layout ready"
                          <> "|Layout waiting"
                      button $ {} (:class-name css/button) (:inner-text "|Open drawer")
                        :style $ {} (:padding "|8px 12px")
                        :on-click $ fn (e d!) (.show drawer-plugin d!)
                      button $ {} (:class-name css/button) (:inner-text |Tips)
                        :style $ {} (:padding "|8px 12px")
                        :on-click $ fn (e d!) (.show help-alert d!)
                  if-let
                    relay-error $ :last-error relay
                    div
                      {} $ :style
                        {} (:padding "|12px 14px") (:border-radius 16) (:background-color |#fff1ec) (:border "|1px solid #f0c4b4") (:font-size 13) (:line-height |1.6) (:color |#a23f1a) (:margin-top 12)
                      <> $ str "|Relay error: " relay-error
                  if-let
                    render-error $ :last-error renderer
                    div
                      {} $ :style
                        {} (:padding "|12px 14px") (:border-radius 16) (:background-color |#fff1ec) (:border "|1px solid #f0c4b4") (:font-size 13) (:line-height |1.6) (:color |#a23f1a) (:margin-top 12)
                      <> $ str "|Validation error: " render-error
                  if
                    > (count channels) 1
                    div
                      {} $ :style
                        {} (:display |flex) (:flex-direction |column) (:gap 12) (:padding 18) (:border-radius 20) (:background-color |#fffaf4) (:border "|1px solid #ead8c7") (:margin-top 12)
                      div
                        {} $ :style
                          {} (:font-size 15) (:font-weight |600) (:color |#6b4528)
                        <> "|Available channels"
                      list->
                        {} $ :style
                          {} (:display |flex) (:gap 10) (:flex-wrap |wrap)
                        -> channels .to-list $ map-indexed
                          fn (idx channel)
                            [] idx $ button
                              {} (:class-name css/button) (:inner-text channel)
                                :style $ {} (:padding "|8px 12px")
                                  :background-color $ if (= channel selected-channel) |#e8b488 |#fff
                                  :border $ if (= channel selected-channel) "|1px solid #cf8b5d" "|1px solid #ead8c7"
                                :on-click $ fn (e d!)
                                  d! $ :: :select-channel channel
                  div
                    {} $ :style
                      {} (:display |flex) (:flex-direction |column) (:gap 16) (:padding 22) (:border-radius 24) (:background-color |#fff7ef) (:border "|1px solid #ecdccf") (:min-height |420px) (:margin-top 12)
                    div
                      {} $ :style
                        {} (:font-size 20) (:font-weight |600)
                      <> "|Rendered Preview"
                    if (nil? selected-channel)
                      div
                        {} $ :style
                          {} (:padding 32) (:border-radius 18) (:border "|1px dashed #d7bca4") (:background-color |#fffbf6) (:font-size 15) (:line-height |1.7) (:color |#8b6c52)
                        if
                          > (count channels) 1
                          <> "|Select a channel to start receiving validated layouts."
                          <> "|Waiting for an active relay channel. Open this page with `?channel=<name>` and send payloads with `edn-relay send --channel <name> '<INPUT>'`."
                      if-let
                        layout $ :layout renderer
                        comp-layout-node layout
                        div
                          {} $ :style
                            {} (:padding 32) (:border-radius 18) (:border "|1px dashed #d7bca4") (:background-color |#fffbf6) (:font-size 15) (:line-height |1.7) (:color |#8b6c52)
                          <> "|Waiting for a validated payload from the relay."
                  .render drawer-plugin
                  .render help-alert
          :examples $ []
        |comp-layout-node $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defcomp comp-layout-node (node)
              match node
                (:column children)
                  list->
                    {} $ :style
                      {} (:display |flex) (:flex-direction |column) (:gap 12) (:align-items |stretch)
                    -> children .to-list $ map-indexed
                      fn (idx child)
                        [] idx $ comp-layout-node child
                (:row children)
                  list->
                    {} $ :style
                      {} (:display |flex) (:flex-direction |row) (:gap 12) (:flex-wrap |wrap) (:align-items |center)
                    -> children .to-list $ map-indexed
                      fn (idx child)
                        [] idx $ comp-layout-node child
                (:card title children)
                  div
                    {} $ :style
                      {} (:display |flex) (:flex-direction |column) (:gap 12) (:padding 16) (:border "|1px solid #e4d4c6") (:border-radius 16) (:background-color |#fffdf9)
                    if-let (title-text title)
                      div
                        {} $ :style
                          {} (:font-size 18) (:font-weight |600) (:color |#7e4f2c)
                        <> title-text
                    list->
                      {} $ :style
                        {} (:display |flex) (:flex-direction |column) (:gap 10)
                      -> children .to-list $ map-indexed
                        fn (idx child)
                          [] idx $ comp-layout-node child
                (:text text)
                  div
                    {} $ :style
                      {} (:font-size 16) (:line-height |1.6) (:color |#2e241c)
                    <> text
                (:badge text)
                  div
                    {} $ :style
                      {} (:display |inline-flex) (:align-items |center) (:padding 8) (:border-radius 999) (:background-color |#f3d7ba) (:color |#7d4d27) (:font-size 12) (:font-weight |600) (:width |fit-content)
                    <> text
                (:divider)
                  div $ {}
                    :style $ {} (:height 1) (:width |100%) (:background-color |#e6d4c4)
                (:button text)
                  button $ {} (:disabled true) (:inner-text text)
                    :style $ {} (:padding 10) (:border "|1px solid #cf8b5d") (:background-color |#e8b488) (:color |#3e2515) (:border-radius 999) (:font-size 14) (:font-weight |600) (:cursor |not-allowed)
                (:input name placeholder value)
                  input $ {} (:disabled true)
                    :value $ or value |
                    :placeholder $ or placeholder (or name |Input)
                    :style $ {} (:padding 10) (:border "|1px solid #d8c8ba") (:border-radius 12) (:font-size 14) (:background-color |#fff) (:min-width |160px)
                (:markdown text)
                  div
                    {} $ :style
                      {} (:padding 18) (:border-radius 18) (:background-color |#fffdf9) (:border "|1px solid #e8d7ca")
                    comp-markdown-block text
                (:mermaid text) (comp-mermaid-block text)
                (:chart kind title series)
                  div
                    {} $ :style
                      {} (:padding 18) (:border-radius 18) (:background-color |#fffdf9) (:border "|1px solid #e8d7ca")
                    comp-chart-block series kind title
                _ $ div
                  {} $ :style
                    {} (:padding 12) (:border "|1px solid #f08c6c") (:border-radius 12) (:background-color |#fff4ef) (:color |#9b3d15)
                  <> "|Unsupported layout node"
          :examples $ []
        |comp-markdown-block $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defcomp comp-markdown-block (text)
              let
                  lines $ split-lines text
                list->
                  {} $ :style
                    {} (:display |flex) (:flex-direction |column) (:gap 8)
                  -> lines .to-list $ map-indexed
                    fn (idx line)
                      [] idx $ cond
                          blank? line
                          div $ {}
                            :style $ {} (:height 6)
                        (starts-with? line "|### ")
                          div
                            {} $ :style
                              {} (:font-size 18) (:font-weight |600) (:color |#6b4528)
                            <> $ slice line 4
                        (starts-with? line "|## ")
                          div
                            {} $ :style
                              {} (:font-size 22) (:font-weight |700) (:color |#583722)
                            <> $ slice line 3
                        (starts-with? line "|# ")
                          div
                            {} $ :style
                              {} (:font-size 28) (:font-weight |700) (:color |#3a2417)
                            <> $ slice line 2
                        (starts-with? line "|- ")
                          div
                            {} $ :style
                              {} (:display |flex) (:align-items |flex-start) (:gap 8) (:font-size 15) (:line-height |1.7) (:color |#2e241c)
                            span
                              {} $ :style
                                {} (:color |#b36a36) (:font-weight |700)
                              <> "|•"
                            <> $ slice line 2
                        (starts-with? line "|> ")
                          div
                            {} $ :style
                              {} (:padding-left 14) (:border-left "|3px solid #d7bca4") (:font-size 15) (:line-height |1.7) (:color |#6e553d)
                            <> $ slice line 2
                        true $ div
                          {} $ :style
                            {} (:font-size 15) (:line-height |1.7) (:color |#2e241c) (:white-space |pre-wrap)
                          <> line
          :examples $ []
        |comp-mermaid-block $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
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
                      :style $ {} (:display |flex) (:flex-direction |column) (:gap 10) (:padding 16) (:border-radius 16) (:border "|1px solid #d9cabf") (:background-color |#fffdf9)
                    div
                      {} $ :style
                        {} (:font-size 13) (:font-weight |700) (:letter-spacing |1px) (:text-transform |uppercase) (:color |#8b6244)
                      <> |Mermaid
                    div $ {} (:class-name |mermaid-output)
                      :style $ {} (:min-height |120px) (:padding 12) (:border-radius 12) (:background-color |#fff) (:overflow |auto) (:border "|1px solid #eadccf") (:color |#6f5743) (:font-size 13) (:line-height |1.6) (:white-space |pre-wrap)
                      :innerHTML $ if (nil? svg-str) "|Rendering Mermaid diagram..." svg-str
          :examples $ []
        |effect-echarts $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defeffect effect-echarts (option) (action el at?)
              let
                  render-chart $ fn ()
                    let
                        existing $ echarts-lib/getInstanceByDom el
                        chart $ if (nil? existing) (echarts-lib/init el) existing
                        plain-option $ to-js-data option
                      do (.!debug js/console "|[echarts] render/raw" option) (.!log js/console "|[echarts] render/plain" plain-option)
                        .!log js/console "|[echarts] render/plain-json" $ js/JSON.stringify plain-option nil 2
                        .!log js/console "|[echarts] host-size" (.-clientWidth el) (.-clientHeight el)
                        .!setOption chart plain-option true
                  dispose-chart $ fn ()
                    let
                        chart $ echarts-lib/getInstanceByDom el
                      when (some? chart) (.!dispose chart)
                case-default action nil
                  :mount $ do (.!debug js/console "|[echarts] mount") (render-chart)
                  :update $ do (.!debug js/console "|[echarts] update") (render-chart)
                  :unmount $ do (.!debug js/console "|[echarts] unmount") (dispose-chart)
          :examples $ []
        |effect-mermaid $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defeffect effect-mermaid (text) (action el at?)
              let
                  payload $ build-mermaid-render-payload text
                case-default action nil
                  :mount $ do (.!debug js/console "|[mermaid] mount" payload)
                    when
                      not $ :empty? payload
                      render-mermaid-on el payload
                  :update $ do (.!debug js/console "|[mermaid] update" payload)
                    when
                      not $ :empty? payload
                      render-mermaid-on el payload
                  :unmount $ .!debug js/console "|[mermaid] unmount"
          :examples $ []
        |ensure-mermaid! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn ensure-mermaid! () $ when
              not $ deref *mermaid-ready
              .!initialize mermaid-lib $ js-object (:startOnLoad false) (:securityLevel |loose) (:theme |neutral)
              reset! *mermaid-ready true
          :examples $ []
        |parse-layout-children $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn parse-layout-children (children path)
              if
                not $ list? children
                raise $ str path "| field :children should be a list"
                foldl children ([])
                  fn (acc child)
                    append acc $ parse-layout-node child (str path |.children)
          :examples $ []
        |parse-layout-node $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn parse-layout-node (node path)
              if
                not $ map? node
                raise $ str path "| expected a map node"
                let
                    node-type $ :type node
                    children $ or (:children node) ([])
                    series $ or (:series node) ([])
                  if
                    not $ string? node-type
                    raise $ str path "| is missing string field :type"
                    case-default node-type
                      raise $ str path "| does not support node type " node-type
                      |column $ %:: LayoutNode :column (parse-layout-children children path)
                      |row $ %:: LayoutNode :row (parse-layout-children children path)
                      |card $ %:: LayoutNode :card (:text node) (parse-layout-children children path)
                      |text $ if
                        and
                          string? $ :text node
                          >
                            count $ :text node
                            , 0
                        %:: LayoutNode :text $ :text node
                        raise $ str path "| text node requires non-empty :text"
                      |badge $ if
                        and
                          string? $ :text node
                          >
                            count $ :text node
                            , 0
                        %:: LayoutNode :badge $ :text node
                        raise $ str path "| badge node requires non-empty :text"
                      |divider $ %:: LayoutNode :divider
                      |button $ if
                        and
                          string? $ :text node
                          >
                            count $ :text node
                            , 0
                        %:: LayoutNode :button $ :text node
                        raise $ str path "| button node requires non-empty :text"
                      |input $ if
                        or
                          some? $ :name node
                          some? $ :placeholder node
                        %:: LayoutNode :input (:name node) (:placeholder node) (:text node)
                        raise $ str path "| input node requires :name or :placeholder"
                      |markdown $ if
                        and
                          string? $ :text node
                          >
                            count $ :text node
                            , 0
                        %:: LayoutNode :markdown $ :text node
                        raise $ str path "| markdown node requires non-empty :text"
                      |mermaid $ if
                        and
                          string? $ :text node
                          >
                            count $ :text node
                            , 0
                        %:: LayoutNode :mermaid $ :text node
                        raise $ str path "| mermaid node requires non-empty :text"
                      |chart $ do
                        if
                          not $ list? series
                          raise $ str path "| chart node requires list field :series"
                        every? series $ fn (item)
                          if
                            not $ map? item
                            raise $ str path "| chart series item should be a map"
                            if
                              and
                                string? $ :label item
                                number? $ :value item
                              , item $ raise (str path "| chart series item requires string :label and number :value")
                        %:: LayoutNode :chart
                          or (:kind node) |bar
                          or (:title node) |
                          , series
          :examples $ []
        |render-mermaid-on $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn render-mermaid-on (el payload)
              hint-fn $ {} (:async true)
              let
                  source $ :source payload
                  graph-id $ :graph-id payload
                  output $ .!querySelector el |.mermaid-output
                if (nil? output) (.!warn js/console "|[mermaid] missing .mermaid-output" el)
                  if
                    some? $ get @*rendered-svgs source
                    .!debug js/console "|[mermaid] skip rendered"
                    do
                      reset! *rendered-svgs $ assoc @*rendered-svgs source :rendering
                      ensure-mermaid!
                      let
                          render-fn $ .-render mermaid-lib
                        try
                          let
                              result $ js-await (.!call render-fn mermaid-lib graph-id source)
                              svg $ .-svg result
                              bind-fns $ .-bindFunctions result
                            do
                              set! (.-innerHTML output) svg
                              when (some? bind-fns) (bind-fns output)
                              reset! *rendered-svgs $ assoc @*rendered-svgs source svg
                              .!debug js/console "|[mermaid] render" $ js-object
                                :length $ count source
                                :graphId graph-id
                          fn (error)
                            do
                              reset! *rendered-svgs $ assoc @*rendered-svgs source false
                              .!error js/console "|[mermaid] render failed" error
          :examples $ []
        |validate-layout $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn validate-layout (layout) (parse-layout-node layout |root)
          :examples $ []
        |validate-layout-node $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn validate-layout-node (node path) (parse-layout-node node path)
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns app.comp.container $ :require (respo-ui.css :as css)
            respo.css :refer $ defstyle
            respo.core :refer $ defcomp defeffect <> >> div button textarea span input list->
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            app.config :refer $ dev?
            |echarts :as echarts-lib
            |mermaid :default mermaid-lib
            respo-alerts.core :refer $ use-alert use-drawer
    |app.config $ %{} :FileEntry
      :defs $ {}
        |build-help-payload $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-help-payload (topics)
              let
                  normalized-topics $ if (list? topics) topics ([])
                {} (:status |ok) (:kind |help) (:renderer |edn-renderer) (:summary renderer-help-overview) (:commands relay-commands) (:topics normalized-topics)
                  :components $ select-component-docs normalized-topics
                  :protocol_docs $ select-protocol-docs normalized-topics
                  :examples $ select-example-docs normalized-topics
          :examples $ []
        |build-skill-payload $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-skill-payload () $ {} (:status |ok) (:kind |skill) (:renderer |edn-renderer) (:title "|edn-renderer Skill") (:text skill-text)
          :examples $ []
        |build-status-payload $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-status-payload (relay)
              {} (:status |ok) (:kind |status) (:renderer |edn-renderer) (:title current-page-title) (:page_url current-page-url) (:commands relay-commands)
                :channel $ :selected-channel relay
                :channels $ or (:channels relay) ([])
          :examples $ []
        |component-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def component-docs $ []
              {} (:name |column) (:summary "|纵向容器，使用 `:children` 顺序渲染子节点。")
                :fields $ [] |children
                :example "|{}\n  :type |column\n  :children $ []\n    {} (:type |text) (:text \"|Hello\")"
              {} (:name |row) (:summary "|横向容器，使用 `:children` 横向排列子节点。")
                :fields $ [] |children
                :example "|{}\n  :type |row\n  :children $ []\n    {} (:type |badge) (:text |A)\n    {} (:type |badge) (:text |B)"
              {} (:name |card) (:summary "|带标题的内容容器，常用于组合多个子节点。")
                :fields $ [] |text |children
                :example "|{}\n  :type |card\n  :text \"|Title\"\n  :children $ []\n    {} (:type |text) (:text \"|Body\")"
              {} (:name |text) (:summary "|普通文本节点。")
                :fields $ [] |text
                :example "|{} (:type |text) (:text \"|Hello\")"
              {} (:name |badge) (:summary "|紧凑状态标签。")
                :fields $ [] |text
                :example "|{} (:type |badge) (:text |preview)"
              {} (:name |divider) (:summary "|水平分隔线。")
                :fields $ []
                :example "|{} (:type |divider)"
              {} (:name |markdown) (:summary "|Markdown 富文本块。")
                :fields $ [] |text
                :example "|{} (:type |markdown) (:text \"|## Title\")"
              {} (:name |mermaid) (:summary "|Mermaid 图节点，` :text ` 为 Mermaid DSL。")
                :fields $ [] |text
                :example "|{} (:type |mermaid) (:text \"|flowchart LR\\n  A --> B\")"
              {} (:name |chart) (:summary "|ECharts 图表节点，支持 `bar`/`line`/`pie`/`scatter`。")
                :fields $ [] |kind |title |series
                :example "|{}\n  :type |chart\n  :kind |line\n  :title \"|Traffic\"\n  :series $ []\n    {} (:label |Mon) (:value 120)"
              {} (:name |button) (:summary "|只读展示按钮。")
                :fields $ [] |text
                :example "|{} (:type |button) (:text |Confirm)"
              {} (:name |input) (:summary "|只读展示输入框。")
                :fields $ [] |name |placeholder |text
                :example "|{} (:type |input) (:name |email) (:placeholder |Email)"
          :examples $ []
        |current-page-title $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def current-page-title $ .-title js/document
          :examples $ []
        |current-page-url $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def current-page-url $ .-href js/location
          :examples $ []
        |current-url-param $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn current-url-param (key) $ let
                params $ new js/URLSearchParams (.-search js/location)
                value $ .!get params key
              if
                and (some? value)
                  > (count value) 0
                , value nil
          :examples $ []
        |current-url-channel $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn current-url-channel () $ current-url-param |channel
          :examples $ []
        |current-relay-url $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn current-relay-url () $ let
                server $ current-url-param |server
                port $ current-url-param |port
              or server $ if (some? port)
                str |ws://127.0.0.1: port
                :relay-url site
          :examples $ []
        |dev? $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def dev? $ = |dev (get-env |mode |release)
          :examples $ []
        |example-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def example-docs $ []
              {} (:name |card-demo) (:summary "|最小 card 示例。") (:payload "|{}\n  :type |card\n  :text \"|CLI Demo\"\n  :children $ []\n    {} (:type |badge) (:text |preview)\n    {} (:type |text) (:text \"|Hello from CLI\")")
              {} (:name |chart-demo) (:summary "|折线图示例。") (:payload "|{}\n  :type |chart\n  :kind |line\n  :title \"|Traffic trend\"\n  :series $ []\n    {} (:label |Mon) (:value 120)\n    {} (:label |Tue) (:value 132)\n    {} (:label |Wed) (:value 148)")
              {} (:name |mermaid-demo) (:summary "|Mermaid 流程图示例。") (:payload "|{}\n  :type |mermaid\n  :text \"|flowchart LR\\n  A --> B\\n  B --> C\"")
          :examples $ []
        |protocol-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def protocol-docs $ []
              {} (:name |channel) (:summary "|每个 renderer 连接只订阅一个当前 channel；URL 上的 `?channel=` 可以直接指定或创建它。发布版页面还支持 `?server=` 或 `?port=` 指向 relay。")
              {} (:name |hello) (:summary "|浏览器连接 relay 后先发送 `hello`，服务端会返回 `hello-ok` 和当前活跃 channel 列表。")
              {} (:name |channel-state) (:summary "|当活跃 channel 列表变化时，relay 会广播 `channel-state`。")
              {} (:name |ack) (:summary "|同一个请求允许多个 receiver 收到事件，但 sender 只接受第一条 `ack`。")
          :examples $ []
        |relay-commands $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def relay-commands $ [] |channels |open-published |send |help |skill |status |open
          :examples $ []
        |renderer-help-overview $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote (def renderer-help-overview "|使用 `edn-relay help` 查询当前 renderer 支持的能力；可以用 `edn-relay help protocol` 看协议摘要，用 `edn-relay help examples` 看示例，用 `edn-relay help chart mermaid` 过滤组件帮助。")
          :examples $ []
        |select-component-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn select-component-docs (topics)
              let
                  normalized-topics $ if (list? topics) topics ([])
                if (empty? normalized-topics) component-docs $ foldl component-docs ([])
                  fn (acc item)
                    if
                      includes? normalized-topics $ :name item
                      append acc item
                      , acc
          :examples $ []
        |select-example-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn select-example-docs (topics)
              let
                  normalized-topics $ if (list? topics) topics ([])
                if (includes? normalized-topics |examples) example-docs $ foldl example-docs ([])
                  fn (acc item)
                    if
                      includes? normalized-topics $ :name item
                      append acc item
                      , acc
          :examples $ []
        |select-protocol-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn select-protocol-docs (topics)
              let
                  normalized-topics $ if (list? topics) topics ([])
                if (includes? normalized-topics |protocol) protocol-docs $ foldl protocol-docs ([])
                  fn (acc item)
                    if
                      includes? normalized-topics $ :name item
                      append acc item
                      , acc
          :examples $ []
        |site $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def site $ {} (:storage-key |workflow) (:relay-url |ws://127.0.0.1:9100)
          :examples $ []
        |skill-text $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def skill-text $ slurp-file |SKILL.md
          :examples $ []
        |slurp-file $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defmacro slurp-file (file-path) (read-file file-path)
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote (ns app.config)
    |app.main $ %{} :FileEntry
      :defs $ {}
        |*reel $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defatom *reel $ -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
          :examples $ []
        |*ws $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote (defatom *ws nil)
          :examples $ []
        |dispatch! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn dispatch! (op)
              when
                and config/dev? $ not= op :states
                js/console.log |Dispatch: op
              let
                  next-reel $ reel-updater updater @*reel op
                reset! *reel next-reel
                when
                  and (some? @*ws)
                    tag-match op
                      (:select-channel _) true
                      _ false
                  sync-selected-channel! @*ws
          :examples $ []
        |ensure-relay! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn ensure-relay! () $ when (nil? @*ws)
              dispatch! $ :: :relay-status |connecting nil
              let
                  relay-url $ config/current-relay-url
                  ws $ new js/WebSocket relay-url
                  client-id $ str |renderer-
                    .!toISOString $ new js/Date
                reset! *ws ws
                .!addEventListener ws |open $ fn (event)
                  dispatch! $ :: :relay-connected client-id ([])
                  sync-selected-channel! ws
                .!addEventListener ws |message $ fn (event)
                  handle-relay-message! ws $ .-data event
                .!addEventListener ws |error $ fn (event)
                  dispatch! $ :: :relay-status |error "|Relay websocket error"
                .!addEventListener ws |close $ fn (event) (reset! *ws nil)
                  dispatch! $ :: :relay-status |closed "|Relay connection closed, retrying..."
                  flipped js/setTimeout 2000 ensure-relay!
          :examples $ []
        |handle-channel-state! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn handle-channel-state! (ws client-id channels)
              let
                  normalized $ if (list? channels) channels ([])
                if (some? client-id)
                  dispatch! $ :: :relay-connected client-id normalized
                  dispatch! $ :: :relay-channels normalized
                when
                  and
                    nil? $ selected-relay-channel
                    = 1 $ count normalized
                  dispatch! $ :: :select-channel (first normalized)
          :examples $ []
        |handle-genui-event! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn handle-genui-event! (ws frame)
              let
                  request-id $ :id frame
                  payload $ :payload frame
                  layout-id $ str |layout- request-id
                let
                    layout $ -> payload validate-layout
                    source $ format-cirru-edn payload
                    ack-payload $ {} (:status |ok) (:layout_id layout-id)
                  dispatch! $ :: :genui-applied request-id layout-id layout source
                  send-genui-ack! ws request-id true ack-payload nil
          :examples $ []
        |handle-relay-message! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn handle-relay-message! (ws raw)
              let
                  frame $ parse-cirru-edn raw
                  kind $ :kind frame
                  payload $ :payload frame
                  op $ if (map? payload) (:op payload) nil
                  selected $ selected-relay-channel
                if (= kind |hello-ok)
                  handle-channel-state! ws (:client_id frame) (:channels frame)
                  if (= kind |channel-state)
                    handle-channel-state! ws nil $ :channels frame
                    if (= kind |event)
                      if
                        and (some? selected)
                          = (:channel frame) selected
                        if
                          includes? ([] |help |skill |status) op
                          handle-renderer-event! ws frame
                          handle-genui-event! ws frame
                        do |ignored
                      if (= kind |warning)
                        .!warn js/console $ or (:error frame) "|Relay warning"
                        if (= kind |error)
                          dispatch! $ :: :relay-status |error
                            or (:error frame) "|Relay error"
                          do |ignored
          :examples $ []
        |handle-renderer-event! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn handle-renderer-event! (ws frame)
              let
                  request-id $ :id frame
                  payload $ :payload frame
                  op $ if (map? payload) (:op payload) nil
                  topics $ if
                    and (map? payload)
                      list? $ :topics payload
                    :topics payload
                    []
                  relay $ get-in @*reel ([] :store :relay)
                do (.!debug js/console "|[renderer] request" payload)
                  if (= op |help)
                    let
                        response-payload $ config/build-help-payload topics
                      send-genui-ack! ws request-id true response-payload nil
                    if (= op |skill)
                      send-genui-ack! ws request-id true (config/build-skill-payload) nil
                      if (= op |status)
                        send-genui-ack! ws request-id true (config/build-status-payload relay) nil
                        send-genui-ack! ws request-id false nil $ str "|Unsupported renderer op: " op
          :examples $ []
        |main! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn main! ()
              println "|Running mode:" $ if config/dev? |dev |release
              if config/dev? $ load-console-formatter!
              render-app!
              add-watch *reel :changes $ fn (reel prev) (render-app!)
              listen-devtools! |k dispatch!
              js/window.addEventListener |beforeunload $ fn (event) (persist-storage!)
              js/window.addEventListener |visibilitychange $ fn (event)
                if (= |hidden js/document.visibilityState) (persist-storage!)
              flipped js/setInterval 60000 persist-storage!
              let
                  raw $ js/localStorage.getItem (:storage-key config/site)
                when (some? raw)
                  dispatch! $ :: :hydrate-storage (parse-cirru-edn raw)
              if-let
                url-channel $ config/current-url-channel
                dispatch! $ :: :select-channel url-channel
              ensure-relay!
              println "|App started."
          :examples $ []
        |mount-target $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def mount-target $ js/document.querySelector |.app
          :examples $ []
        |persist-storage! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn persist-storage! ()
              println "|Saved at" $ .!toISOString (new js/Date)
              js/localStorage.setItem (:storage-key config/site)
                format-cirru-edn $ :store @*reel
          :examples $ []
        |reload! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn reload! () $ if (nil? build-errors)
              do (remove-watch *reel :changes) (clear-cache!)
                add-watch *reel :changes $ fn (reel prev) (render-app!)
                reset! *reel $ refresh-reel @*reel schema/store updater
                ensure-relay!
                hud! |ok~ |Ok
              hud! |error build-errors
          :examples $ []
        |render-app! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn render-app! () $ render! mount-target (comp-container @*reel) dispatch!
          :examples $ []
        |selected-relay-channel $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn selected-relay-channel () $ get-in @*reel ([] :store :relay :selected-channel)
          :examples $ []
        |send-genui-ack! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn send-genui-ack! (ws request-id ok? payload error-message)
              send-relay-frame! ws $ {} (:kind |ack) (:id request-id) (:ok ok?) (:payload payload) (:error error-message)
          :examples $ []
        |send-relay-frame! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn send-relay-frame! (ws frame)
              .!send ws $ format-cirru-edn frame
          :examples $ []
        |sync-selected-channel! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn sync-selected-channel! (ws)
              let
                  client-id $ get-in @*reel ([] :store :relay :client-id)
                  selected $ selected-relay-channel
                  channels $ if (some? selected) ([] selected) ([])
                send-relay-frame! ws $ {} (:kind |hello) (:role |receiver) (:client_id client-id) (:channels channels)
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns app.main $ :require
            respo.core :refer $ render! clear-cache!
            app.comp.container :refer $ comp-container validate-layout
            app.updater :refer $ updater
            app.schema :as schema
            reel.util :refer $ listen-devtools!
            reel.core :refer $ reel-updater refresh-reel
            reel.schema :as reel-schema
            app.config :as config
            |./calcit.build-errors :default build-errors
            |bottom-tip :default hud!
    |app.schema $ %{} :FileEntry
      :defs $ {}
        |store $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def store $ {}
              :states $ {}
                :cursor $ []
              :relay $ {} (:status |idle) (:client-id nil) (:last-error nil) (:selected-channel nil)
                :channels $ []
              :renderer $ {} (:layout nil) (:layout-id nil) (:layout-source |) (:last-request nil) (:last-error nil)
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote (ns app.schema)
    |app.updater $ %{} :FileEntry
      :defs $ {}
        |updater $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn updater (store op op-id op-time)
              tag-match op
                (:states cursor s) (update-states store cursor s)
                (:hydrate-storage data) data
                (:relay-connected client-id channels)
                  -> store
                    assoc-in ([] :relay :status) |ready
                    assoc-in ([] :relay :client-id) client-id
                    assoc-in ([] :relay :channels) channels
                    assoc-in ([] :relay :last-error) nil
                (:relay-channels channels)
                  assoc-in store ([] :relay :channels) channels
                (:select-channel channel)
                  -> store
                    assoc-in ([] :relay :selected-channel) channel
                    assoc-in ([] :renderer :layout) nil
                    assoc-in ([] :renderer :layout-id) nil
                    assoc-in ([] :renderer :layout-source) |
                    assoc-in ([] :renderer :last-request) nil
                    assoc-in ([] :renderer :last-error) nil
                (:relay-status status message)
                  -> store
                    assoc-in ([] :relay :status) status
                    assoc-in ([] :relay :last-error) message
                (:genui-applied request-id layout-id layout source)
                  -> store
                    assoc-in ([] :renderer :layout) layout
                    assoc-in ([] :renderer :layout-id) layout-id
                    assoc-in ([] :renderer :layout-source) source
                    assoc-in ([] :renderer :last-request) request-id
                    assoc-in ([] :renderer :last-error) nil
                (:genui-failed request-id message source)
                  -> store
                    assoc-in ([] :renderer :layout-source) source
                    assoc-in ([] :renderer :last-request) request-id
                    assoc-in ([] :renderer :last-error) message
                _ $ do (eprintln "|unknown op:" op) store
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns app.updater $ :require
            respo.cursor :refer $ update-states
