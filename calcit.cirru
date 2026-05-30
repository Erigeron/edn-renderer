
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
            def LayoutNode $ defenum LayoutNode (:column :list) (:row :list) (:card :dynamic :list) (:text :string) (:badge :string) (:divider) (:button :string) (:input :dynamic :dynamic :dynamic) (:markdown :string) (:mermaid :string) (:chart :dynamic :dynamic :list) (:math :dynamic :dynamic)
          :examples $ []
        |append-mathml-child! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn append-mathml-child! (el child path)
              if (string? child)
                .!appendChild el $ .!createTextNode js/document child
                if (number? child)
                  .!appendChild el $ .!createTextNode js/document (str child)
                  if (list? child)
                    .!appendChild el $ build-mathml-element child path
                    raise $ str path "| invalid MathML child, expected string, number, or list"
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
        |build-mathml-element $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-mathml-element (expr path)
              let
                  tag-name $ first expr
                  children $ or (rest expr) ([])
                  el $ .!createElementNS js/document mathml-namespace tag-name
                do
                  foldl children nil $ fn (acc child)
                    do
                      append-mathml-child! el child $ str path |/ tag-name
                      , acc
                  , el
          :examples $ []
        |build-mathml-root $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-mathml-root (expr display)
              let
                  root $ .!createElementNS js/document mathml-namespace |math
                do
                  .!setAttribute root |display $ math-display-value display
                  .!appendChild root $ build-mathml-element expr |math
                  , root
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
                  history $ if
                    list? $ :history renderer
                    :history renderer
                    []
                  selected-history $ :selected-history renderer
                  storage-status $ or (:storage-status renderer) |idle
                  storage-error $ :storage-error renderer
                  storage-entries $ if
                    list? $ :storage-entries renderer
                    :storage-entries renderer
                    []
                  selected-storage $ :selected-storage renderer
                  workspace-entry $ :workspace-entry renderer
                  detail-status $ if
                    and (some? selected-storage)
                      = (:kind selected-storage) :workspace-report
                    , |workspace storage-status
                  drawer-view $ or (:drawer-view renderer) |history
                  drawer-plugin $ use-drawer (>> states :drawer)
                    {}
                      :style $ {} (:width 820) (:min-width 0) (:max-width "|calc(100vw - 24px)") (:padding "|12px 12px 14px") (:gap 12) (:background-color |#f7f7f3) (:border-left "|1px solid #d7d7cf") (:box-shadow "|-12px 0 28px hsla(210, 8%, 18%, 0.12)") (:overflow |auto)
                      :container-style $ if drawer-open?
                        {} (:position :fixed) (:top 0) (:right 0) (:bottom 0) (:left 0) (:z-index |40)
                        {}
                      :backdrop-style $ {} (:background-color "|hsla(210, 10%, 18%, 0.08)") (:backdrop-filter "|blur(8px)")
                      :render $ fn (on-close)
                        div
                          {} $ :style
                            {} (:display |flex) (:flex-direction |column) (:gap 12)
                          div
                            {} $ :style
                              {} (:display |flex) (:justify-content |space-between) (:align-items |center) (:gap 10) (:flex-wrap |wrap)
                            div
                              {} $ :style
                                {} (:display |flex) (:align-items |center) (:gap 8) (:flex-wrap |wrap)
                              div
                                {} $ :style
                                  {} (:font-size 15) (:font-weight |700) (:color |#1f2933)
                                <> $ if (= drawer-view |library) |Library |History
                              div
                                {} $ :style
                                  {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                <> $ str "|Messages: " (count history)
                              if (some? selected-channel)
                                div
                                  {} $ :style
                                    {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                  <> $ str "|Channel: " selected-channel
                              div
                                {} $ :style
                                  {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                <> $ str "|Reports: " (count storage-entries)
                            button $ {} (:class-name css/button) (:inner-text |Close)
                              :style $ {} (:padding "|5px 9px") (:font-size 11)
                              :on-click $ fn (e d!) (on-close d!)
                          div
                            {} $ :style
                              {} (:display |flex) (:align-items |stretch) (:gap 12) (:flex-wrap |wrap)
                            div
                              {} $ :style
                                {} (:width 290) (:max-width |100%) (:display |flex) (:flex-direction |column) (:gap 8)
                              div
                                {} $ :style
                                  {} (:font-size 12) (:font-weight |600) (:color |#4b5563)
                                <> $ if (= drawer-view |library) "|Library Items" |Messages
                              if (= drawer-view |library)
                                div
                                  {} $ :style
                                    {} (:display |flex) (:flex-direction |column) (:gap 6) (:max-height "|calc(100vh - 180px)") (:overflow |auto)
                                  if-let (item workspace-entry)
                                    let
                                        active? $ if-let (current selected-storage)
                                          = (:kind current) :workspace-report
                                          , false
                                      div
                                        {}
                                          :style $ {} (:padding "|8px 10px") (:border-radius 12)
                                            :border $ if active? "|1px solid #8a8f98" "|1px solid #d7d7cf"
                                            :background-color $ if active? |#eef1f4 |#ffffff
                                            :cursor |pointer
                                            :display |flex
                                            :flex-direction |column
                                            :gap 4
                                          :on-click $ fn (e d!)
                                            d! $ :: :load-workspace-report
                                        div
                                          {} $ :style
                                            {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                          <> $ or (:name item) "|Current workspace"
                                        div
                                          {} $ :style
                                            {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                          <> $ or (:path item) |
                                  if
                                    > (count storage-entries) 0
                                    list->
                                      {} $ :style
                                        {} (:display |flex) (:flex-direction |column) (:gap 6)
                                      -> storage-entries .to-list $ map-indexed
                                        fn (idx item)
                                          let
                                              active? $ if-let (current selected-storage)
                                                if
                                                  = (:kind current) :workspace-report
                                                  , false $ = (:name item) (:name current)
                                                , false
                                            [] idx $ div
                                              {}
                                                :style $ {} (:padding "|8px 10px") (:border-radius 12)
                                                  :border $ if active? "|1px solid #8a8f98" "|1px solid #d7d7cf"
                                                  :background-color $ if active? |#eef1f4 |#ffffff
                                                  :cursor |pointer
                                                  :display |flex
                                                  :flex-direction |column
                                                  :gap 4
                                                :on-click $ fn (e d!)
                                                  d! $ :: :load-stored-report (:name item)
                                              div
                                                {} $ :style
                                                  {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                                <> $ or (:name item) "|Saved report"
                                              div
                                                {} $ :style
                                                  {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                                <> $ or (:path item) |
                                    div
                                      {} $ :style
                                        {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                      <> "|No saved reports for current channel yet."
                                if
                                  > (count history) 0
                                  list->
                                    {} $ :style
                                      {} (:display |flex) (:flex-direction |column) (:gap 6) (:max-height "|calc(100vh - 180px)") (:overflow |auto)
                                    -> history .to-list $ map-indexed
                                      fn (idx item)
                                        let
                                            active? $ if-let (current selected-history)
                                              = (:raw item) (:raw current)
                                              , false
                                            meta-channel $ or (:channel item) |session
                                            meta-request $ or (:request-id item) |-
                                          [] idx $ div
                                            {}
                                              :style $ {} (:padding "|8px 10px") (:border-radius 12)
                                                :border $ if active? "|1px solid #8a8f98" "|1px solid #d7d7cf"
                                                :background-color $ if active? |#eef1f4 |#ffffff
                                                :cursor |pointer
                                                :display |flex
                                                :flex-direction |column
                                                :gap 4
                                                :opacity $ if (:matched? item) |1 |0.72
                                              :on-click $ fn (e d!)
                                                d! $ :: :select-history item
                                            div
                                              {} $ :style
                                                {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                              <> $ or (:summary item) |Message
                                            div
                                              {} $ :style
                                                {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                              <> $ str
                                                or (:kind item) |unknown
                                                , | / meta-channel | / meta-request
                                  div
                                    {} $ :style
                                      {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|No relay messages yet."
                            div
                              {} $ :style
                                {} (:flex |1) (:min-width 280) (:display |flex) (:flex-direction |column) (:gap 8)
                              div
                                {} $ :style
                                  {} (:font-size 12) (:font-weight |600) (:color |#4b5563)
                                <> |Detail
                              if (= drawer-view |library)
                                if-let (item selected-storage)
                                  div
                                    {} $ :style
                                      {} (:display |flex) (:flex-direction |column) (:gap 8)
                                    div
                                      {} $ :style
                                        {} (:font-size 14) (:font-weight |700) (:color |#1f2933)
                                      <> $ or (:name item) "|Saved report"
                                    div
                                      {} $ :style
                                        {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                                      div
                                        {} $ :style
                                          {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Status: " detail-status
                                      if (some? selected-channel)
                                        div
                                          {} $ :style
                                            {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                          <> $ str "|Channel: " selected-channel
                                    textarea $ {}
                                      :value $ format-cirru-edn
                                        {}
                                          :name $ or (:name item) |-
                                          :path $ or (:path item) |-
                                          :status detail-status
                                      :read-only true
                                      :spell-check false
                                      :placeholder "|Library item detail"
                                      :style $ {} (:width |100%) (:min-height "|calc(100vh - 320px)") (:padding 12) (:box-sizing |border-box) (:border-radius 14) (:border "|1px solid #d7d7cf") (:background-color |#ffffff) (:font-family |Monaco) (:font-size 12) (:line-height |1.6) (:resize |vertical)
                                  div
                                    {} $ :style
                                      {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|Click the current workspace snapshot or a saved report to load it into the preview."
                                if-let (item selected-history)
                                  div
                                    {} $ :style
                                      {} (:display |flex) (:flex-direction |column) (:gap 8)
                                    div
                                      {} $ :style
                                        {} (:font-size 14) (:font-weight |700) (:color |#1f2933)
                                      <> $ or (:summary item) |Message
                                    div
                                      {} $ :style
                                        {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                                      div
                                        {} $ :style
                                          {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Kind: "
                                          or (:kind item) |unknown
                                      div
                                        {} $ :style
                                          {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Channel: "
                                          or (:channel item) |session
                                      div
                                        {} $ :style
                                          {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Request: "
                                          or (:request-id item) |-
                                    if (:matched? item)
                                      div $ {}
                                      div
                                        {} $ :style
                                          {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#f4f4f1) (:border "|1px solid #deded8") (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                        <> "|This message did not match the current channel filter."
                                    textarea $ {}
                                      :value $ or (:raw item) |
                                      :read-only true
                                      :spell-check false
                                      :placeholder "|Relay frame detail"
                                      :style $ {} (:width |100%) (:min-height "|calc(100vh - 320px)") (:padding 12) (:box-sizing |border-box) (:border-radius 14) (:border "|1px solid #d7d7cf") (:background-color |#ffffff) (:font-family |Monaco) (:font-size 12) (:line-height |1.6) (:resize |vertical)
                                  div
                                    {} $ :style
                                      {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|Click a message to inspect its raw relay frame."
                          when dev? $ comp-reel (>> states :reel) reel ({})
                  help-alert $ use-alert (>> states :help)
                    {} $ :text "|Use History to inspect recent relay frames and the raw Cirru EDN being rendered."
                do (effect-page-title selected-channel)
                  div
                    {} $ :style
                      {} (:min-height |100vh) (:padding 12) (:box-sizing |border-box) (:background-color |#efefeb) (:color |#1f2933) (:font-family |Avenir)
                    div
                      {} $ :style
                        {} (:display |flex) (:justify-content |space-between) (:align-items |center) (:gap 8) (:padding "|6px 8px") (:border-radius 12) (:background-color |#fbfbf8) (:border "|1px solid #d7d7cf") (:flex-wrap |wrap)
                      div
                        {} $ :style
                          {} (:display |flex) (:align-items |center) (:gap 6) (:flex-wrap |wrap)
                        div
                          {} $ :style
                            {} (:font-size 15) (:font-weight |700) (:line-height |1)
                          <> "|EDN Renderer"
                        div
                          {} $ :style
                            {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                          if (some? selected-channel)
                            <> $ str "|Channel: " selected-channel
                            <> "|No channel"
                      div
                        {} $ :style
                          {} (:display |flex) (:gap 6) (:flex-wrap |wrap) (:align-items |center) (:justify-content |flex-end)
                        div
                          {} $ :style
                            {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#f4f4f1) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                          <> $ str "|Relay: "
                            or (:status relay) |idle
                        div
                          {} $ :style
                            {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#f4f4f1) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                          if
                            some? $ :layout-id renderer
                            <> |Ready
                            <> |Waiting
                        button $ {} (:class-name css/button)
                          :inner-text $ str "|History " (count history)
                          :style $ {} (:padding "|5px 8px") (:font-size 11)
                          :on-click $ fn (e d!)
                            do
                              d! $ :: :open-history-drawer
                              .show drawer-plugin d!
                        button $ {} (:class-name css/button) (:inner-text |Library)
                          :disabled $ nil? selected-channel
                          :style $ {} (:padding "|5px 8px") (:font-size 11)
                          :on-click $ fn (e d!)
                            do
                              d! $ :: :open-library-drawer
                              .show drawer-plugin d!
                              d! $ :: :request-storage-list
                        button $ {} (:class-name css/button) (:inner-text |Save)
                          :disabled $ nil? (:layout-dsl renderer)
                          :style $ {} (:padding "|5px 8px") (:font-size 11)
                          :on-click $ fn (e d!)
                            d! $ :: :save-current-report
                        button $ {} (:class-name css/button) (:inner-text |Tips)
                          :style $ {} (:padding "|5px 8px") (:font-size 11)
                          :on-click $ fn (e d!) (.show help-alert d!)
                    if-let
                      relay-error $ :last-error relay
                      div
                        {} $ :style
                          {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff1ec) (:border "|1px solid #f0c4b4") (:font-size 12) (:line-height |1.5) (:color |#a23f1a) (:margin-top 8)
                        <> $ str "|Relay error: " relay-error
                    if-let
                      render-error $ :last-error renderer
                      div
                        {} $ :style
                          {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff1ec) (:border "|1px solid #f0c4b4") (:font-size 12) (:line-height |1.5) (:color |#a23f1a) (:margin-top 8)
                        <> $ str "|Validation error: " render-error
                    if-let (current-storage-error storage-error)
                      div
                        {} $ :style
                          {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff7e9) (:border "|1px solid #e8c48f") (:font-size 12) (:line-height |1.5) (:color |#8a541d) (:margin-top 8)
                        <> $ str "|Storage error: " current-storage-error
                    if
                      > (count channels) 1
                      div
                        {} $ :style
                          {} (:display |flex) (:flex-direction |column) (:gap 6) (:padding 10) (:border-radius 12) (:background-color |#fbfbf8) (:border "|1px solid #d7d7cf") (:margin-top 8)
                        div
                          {} $ :style
                            {} (:font-size 12) (:font-weight |600) (:color |#4b5563)
                          <> |Channels
                        list->
                          {} $ :style
                            {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                          -> channels .to-list $ map-indexed
                            fn (idx channel)
                              [] idx $ button
                                {} (:class-name css/button) (:inner-text channel)
                                  :style $ {} (:padding "|5px 8px") (:font-size 11)
                                    :background-color $ if (= channel selected-channel) |#dce3ea |#ffffff
                                    :border $ if (= channel selected-channel) "|1px solid #8a8f98" "|1px solid #d7d7cf"
                                  :on-click $ fn (e d!)
                                    d! $ :: :select-channel channel
                    div
                      {} $ :style
                        {} (:display |flex) (:flex-direction |column) (:gap 10) (:padding 12) (:border-radius 16) (:background-color |#fbfbf8) (:border "|1px solid #d7d7cf") (:min-height |420px) (:margin-top 8)
                      div
                        {} $ :style
                          {} (:font-size 13) (:font-weight |600) (:color |#4b5563)
                        <> |Preview
                      if (nil? selected-channel)
                        div
                          {} $ :style
                            {} (:padding 20) (:border-radius 14) (:border "|1px dashed #d7d7cf") (:background-color |#f5f5f1) (:font-size 13) (:line-height |1.6) (:color |#6b7280)
                          if
                            > (count channels) 1
                            <> "|Select a channel to start receiving layouts."
                            <> "|Waiting for a relay channel. Open this page with ?channel=<name>."
                        if-let
                          layout $ :layout renderer
                          comp-layout-node layout
                          div
                            {} $ :style
                              {} (:padding 20) (:border-radius 14) (:border "|1px dashed #d7d7cf") (:background-color |#f5f5f1) (:font-size 13) (:line-height |1.6) (:color |#6b7280)
                            <> "|Waiting for validated payloads."
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
                (:math expr display) (comp-math-block expr display)
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
        |comp-math-block $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defcomp comp-math-block (expr display)
              let
                  block? $ = (math-display-value display) |block
                [] (effect-mathml expr display)
                  div $ {} (:class-name |mathml-host)
                    :style $ merge
                      {} (:padding 18) (:border-radius 18) (:background-color |#fffdf9) (:border "|1px solid #e8d7ca") (:overflow |auto) (:color |#2e241c) (:max-width |100%) (:align-self |flex-start)
                      if block?
                        {} $ :width |100%
                        {} $ :width |fit-content
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
        |effect-mathml $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defeffect effect-mathml (expr display) (action el at?)
              case-default action nil
                :mount $ render-mathml-on el expr display
                :update $ render-mathml-on el expr display
                :unmount $ set! (.-innerHTML el) |
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
        |effect-page-title $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defeffect effect-page-title (selected-channel) (action el at?)
              let
                  next-title $ page-title-text selected-channel
                case-default action nil
                  :mount $ set! (.-title js/document) next-title
                  :update $ set! (.-title js/document) next-title
                  :unmount $ set! (.-title js/document) (page-title-text nil)
          :examples $ []
        |ensure-mermaid! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn ensure-mermaid! () $ when
              not $ deref *mermaid-ready
              .!initialize mermaid-lib $ js-object (:startOnLoad false) (:securityLevel |loose) (:theme |neutral)
              reset! *mermaid-ready true
          :examples $ []
        |math-display-value $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn math-display-value (display)
              if (= display |block) |block |inline
          :examples $ []
        |mathml-namespace $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote (def mathml-namespace |http://www.w3.org/1998/Math/MathML)
          :examples $ []
        |page-title-text $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn page-title-text (selected-channel)
              str |EDN-Renderer/ $ or selected-channel |waiting
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
                              , true $ raise (str path "| chart series item requires string :label and number :value")
                        %:: LayoutNode :chart
                          or (:kind node) |bar
                          or (:title node) |
                          , series
                      |math $ do
                        validate-mathml-expr (:expr node) (str path |.expr)
                        %:: LayoutNode :math (:expr node)
                          math-display-value $ :display node
          :examples $ []
        |render-mathml-on $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn render-mathml-on (el expr display)
              let
                  root $ build-mathml-root expr display
                do
                  set! (.-innerHTML el) |
                  .!appendChild el root
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
        |validate-mathml-child $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn validate-mathml-child (child path)
              if
                or (string? child) (number? child)
                , child $ if (list? child) (validate-mathml-expr child path)
                  raise $ str path "| invalid MathML child, expected string, number, or list"
          :examples $ []
        |validate-mathml-expr $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn validate-mathml-expr (expr path)
              if
                not $ list? expr
                raise $ str path "| math node requires list field :expr"
                if (empty? expr)
                  raise $ str path "| math expression should not be empty"
                  let
                      tag-name $ first expr
                      children $ or (rest expr) ([])
                    if
                      not $ string? tag-name
                      raise $ str path "| math expression requires string tag name"
                      do
                        foldl children nil $ fn (acc child)
                          do
                            validate-mathml-child child $ str path |/ tag-name
                            , acc
                        , expr
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
                {} (:status :ok) (:kind :help) (:renderer |edn-renderer) (:summary renderer-help-overview) (:commands relay-commands) (:topics normalized-topics)
                  :components $ select-component-docs normalized-topics
                  :protocol_docs $ select-protocol-docs normalized-topics
                  :examples $ select-example-docs normalized-topics
          :examples $ []
        |build-skill-payload $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-skill-payload (topics)
              let
                  normalized-topics $ if (list? topics) topics ([])
                  full? $ includes? normalized-topics |full
                  text $ if full? skill-text
                    if (empty? normalized-topics) skill-overview $ build-skill-text normalized-topics
                {} (:status :ok) (:kind :skill) (:renderer |edn-renderer)
                  :title $ if full? "|edn-renderer Skill (full)" "|edn-renderer Skill"
                  :text text
          :examples $ []
        |build-skill-text $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-skill-text (topics)
              let
                  sections $ select-skill-sections topics
                if (empty? sections) skill-overview $ foldl sections skill-overview
                  fn (acc item)
                    str acc "|\n\n## " (:title item) "|\n\n" $ :text item
          :examples $ []
        |build-status-payload $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-status-payload (relay renderer)
              {} (:status :ok) (:kind :status) (:renderer |edn-renderer)
                :title $ current-page-title
                :page_url $ current-page-url
                :commands relay-commands
                :channel $ :selected-channel relay
                :channels $ or (:channels relay) ([])
                :layout_id $ :layout-id renderer
                :last_request $ :last-request renderer
                :layout_ready? $ some? (:layout-dsl renderer)
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
              {} (:name |math) (:summary "|MathML Core 节点，使用 Cirru EDN list 简写 `:expr` 描述公式，再由浏览器原生 MathML 渲染。")
                :fields $ [] |expr |display
                :example "|{}\n  :type |math\n  :display |block\n  :expr $ [] |mfrac\n    [] |mrow\n      [] |mi |a\n      [] |mo |+\n      [] |mi |b\n    [] |msqrt\n      [] |mi |c"
              {} (:name |button) (:summary "|只读展示按钮。")
                :fields $ [] |text
                :example "|{} (:type |button) (:text |Confirm)"
              {} (:name |input) (:summary "|只读展示输入框。")
                :fields $ [] |name |placeholder |text
                :example "|{} (:type |input) (:name |email) (:placeholder |Email)"
          :examples $ []
        |current-page-title $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn current-page-title () $ .-title js/document
          :examples $ []
        |current-page-url $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn current-page-url () $ .-href js/location
          :examples $ []
        |current-relay-url $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn current-relay-url () $ let
                server $ current-url-param |server
                port $ current-url-param |port
              or server $ if (some? port) (str |ws://127.0.0.1: port) (:relay-url site)
          :examples $ []
        |current-url-channel $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn current-url-channel () $ current-url-param |channel
          :examples $ []
        |current-url-param $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn current-url-param (key)
              let
                  params $ new js/URLSearchParams (.-search js/location)
                  value $ .!get params key
                if
                  and (some? value)
                    > (count value) 0
                  , value nil
          :examples $ []
        |dev? $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def dev? $ = |dev (get-env |mode |release)
          :examples $ []
        |example-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def example-docs $ []
              {} (:name |card-demo) (:summary "|最小 card 示例。") (:payload "|{}\n  :type |card\n  :text \"|CLI Demo\"\n  :children $ []\n    {} (:type |badge) (:text |preview)\n    {} (:type |text) (:text \"|Hello from CLI\")")
              {} (:name |layout-summary-demo) (:summary "|查询当前 layout summary tree。") (:payload "|{}\n  :op :layout")
              {} (:name |layout-snapshot-demo) (:summary "|查询当前 layout 的稳定裁剪快照，适合脚本化验证。") (:payload "|{}\n  :op :snapshot")
              {} (:name |layout-node-demo) (:summary "|按路径读取一个节点的完整 DSL。") (:payload "|{}\n  :op :node\n  :path |1.2")
              {} (:name |layout-patch-demo) (:summary "|按路径局部更新节点属性。") (:payload "|{}\n  :op :patch\n  :path |1\n  :changes $ {} (:text \"|Updated title\")")
              {} (:name |layout-replace-demo) (:summary "|按路径替换整棵子树。") (:payload "|{}\n  :op :replace\n  :path |2.1\n  :node $ {} (:type |text) (:text \"|Replaced from CLI\")")
              {} (:name |chart-demo) (:summary "|折线图示例。") (:payload "|{}\n  :type |chart\n  :kind |line\n  :title \"|Traffic trend\"\n  :series $ []\n    {} (:label |Mon) (:value 120)\n    {} (:label |Tue) (:value 132)\n    {} (:label |Wed) (:value 148)")
              {} (:name |math-fraction-demo) (:summary "|MathML 分式示例。") (:payload "|{}\n  :type |math\n  :display |block\n  :expr $ [] |mfrac\n    [] |mrow\n      [] |mi |a\n      [] |mo |+\n      [] |mi |b\n    [] |msqrt\n      [] |mi |c")
              {} (:name |math-quadratic-demo) (:summary "|MathML 二次方程求根公式。") (:payload "|{}\n  :type |math\n  :display |block\n  :expr $ [] |mfrac\n    [] |mrow\n      [] |mo |−\n      [] |mi |b\n      [] |mo |±\n      [] |msqrt\n        [] |mrow\n          [] |msup\n            [] |mi |b\n            [] |mn |2\n          [] |mo |−\n          [] |mn |4\n          [] |mi |a\n          [] |mi |c\n    [] |mrow\n      [] |mn |2\n      [] |mi |a")
              {} (:name |mermaid-demo) (:summary "|Mermaid 流程图示例。") (:payload "|{}\n  :type |mermaid\n  :text \"|flowchart LR\\n  A --> B\\n  B --> C\"")
          :examples $ []
        |protocol-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def protocol-docs $ []
              {} (:name |channel) (:summary "|每个 renderer 连接只订阅一个当前 channel；URL 上的 `?channel=` 可以直接指定或创建它。发布版页面还支持 `?server=` 或 `?port=` 指向 relay。")
              {} (:name |hello) (:summary "|浏览器连接 relay 后先发送 `hello`，服务端会返回 `hello-ok` 和当前活跃 channel 列表。")
              {} (:name |channel-state) (:summary "|当活跃 channel 列表变化时，relay 会广播 `channel-state`。")
              {} (:name |ack) (:summary "|同一个请求允许多个 receiver 收到事件，但 sender 只接受第一条 `ack`。")
              {} (:name |editing) (:summary "|局部编辑推荐顺序是先 `:layout` 看 summary tree，再用 `:node` 读取完整 DSL，最后按改动大小选择 `:patch` 或 `:replace`。成功响应都会回新的 `:layout_id`，并附当前节点 `:summary`，变更类操作还会附 `:dsl`。")
              {} (:name |layout) (:summary "|CLI 上优先用 `{:op :layout}` 查询当前 layout 概览；可附 `:path` 只看某个子树。summary 节点会带 `:path`、`:type`、`:child-count` 和少量摘要字段。")
              {} (:name |snapshot) (:summary "|脚本化验证优先用 `{:op :snapshot}` 查询稳定的裁剪版 layout 树；默认返回整棵树，也支持 `:path` 只抓某个子树。返回字段刻意裁剪，避免测试依赖完整 DSL。")
              {} (:name |node) (:summary "|用 `:op :node` + `:path \"1.2.3\"` 读取某个节点的完整 DSL。路径使用 1-based children 索引，`root` 表示整棵树；成功时同时返回 `:dsl`、`:source` 和 `:summary`。")
              {} (:name |patch) (:summary "|用 `:op :patch` + `:path` + `:changes` 局部合并节点属性，renderer 会重新验证整棵 layout；成功后立即局部更新页面，并返回目标节点新的 `:dsl` 与 `:summary`。")
              {} (:name |replace) (:summary "|用 `:op :replace` + `:path` + `:node` 直接替换某个节点 DSL，适合结构性修改；成功后同样会重新验证整棵树，并返回替换结果。")
              {} (:name |storage) (:summary "|页面上的 `Save` 和 `Library` 通过 relay 保留 channel `__relay_store__` 工作。`Save` 会把当前 report 落到 `~/.config/ed-relay/<channel>/`，`Library` 会列出同 channel 的 `.cirru` 文件并加载回当前预览。")
          :examples $ []
        |relay-commands $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def relay-commands $ [] |send |help |skill |status |open
          :examples $ []
        |renderer-help-overview $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote (def renderer-help-overview "|默认 `edn-relay help --channel <name>` 只返回总览；需要细节时再追加 topic，例如 `components`、`math`、`protocol`、`storage`、`editing`、`examples`、`layout`、`snapshot`、`layout-patch-demo`、`math-fraction-demo`，避免一次返回全部组件配置和案例。")
          :examples $ []
        |select-component-docs $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn select-component-docs (topics)
              let
                  normalized-topics $ if (list? topics) topics ([])
                if (includes? normalized-topics |components) component-docs $ foldl component-docs ([])
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
        |select-skill-sections $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn select-skill-sections (topics)
              let
                  normalized-topics $ if (list? topics) topics ([])
                if (includes? normalized-topics |all) skill-sections $ foldl skill-sections ([])
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
        |skill-overview $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote (def skill-overview "|使用 `edn-relay skill --channel <name>` 获取高层工作流；默认只返回总览。需要细节时追加 topic，例如 `workflow`、`help`、`storage`、`layout`、`math`、`validation`；如果确实要整份文档，再用 `full`。")
          :examples $ []
        |skill-sections $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def skill-sections $ []
              {} (:name |workflow) (:title |Workflow) (:text "|1. 先 `edn-relay help --channel <name>` 看总览。\n2. 再用 `help --channel <name> <topic>` 把范围收窄到组件、协议或示例。\n3. 最后才运行 `edn-relay send --channel <name> ...` 发 payload。")
              {} (:name |help) (:title "|Help Queries") (:text "|默认 `help` 只返回总览。要列出全部组件，用 `edn-relay help --channel <name> components`；要看 MathML，用 `edn-relay help --channel <name> math`；要看局部编辑流程，用 `edn-relay help --channel <name> editing`；要看脚本化快照接口，用 `edn-relay help --channel <name> snapshot`；要看具体案例，用 `edn-relay help --channel <name> layout-patch-demo`。")
              {} (:name |storage) (:title |Storage) (:text "|页面上已有有效 report 时，可以直接点 `Save` 把当前内容保存到 `~/.config/ed-relay/<channel>/`。点 `Library` 会请求 relay 列出当前 channel 下的 `.cirru` 文件，并在点击条目后把保存时的 layout 加载回当前预览。CLI 想查这个能力时，优先用 `edn-relay help --channel <name> storage`。")
              {} (:name |editing) (:title "|Editing Workflow") (:text "|先用 `edn-relay send --channel <name> '{}` + `:op :snapshot` 或 `:op :layout` 获取裁剪过的概览树，再用 `:op :node` + `:path` 读取完整 DSL。只改属性时优先 `:patch` + `:changes`，结构变化再用 `:replace`。每次成功都会回新的 `:layout_id`、目标节点 `:summary`，并在 `node/patch/replace` 返回完整 `:dsl`。")
              {} (:name |layout) (:title "|Layout Editing") (:text "|局部编辑默认走 `snapshot/layout -> node -> patch/replace`。脚本化验证优先 `snapshot`，人工排查优先 `layout`。路径使用 1-based children 索引，`root` 表示整棵树；如果 agent 还不确定 payload 形状，先查 `layout-summary-demo`、`layout-snapshot-demo`、`layout-node-demo`、`layout-patch-demo`。")
              {} (:name |math) (:title |MathML) (:text "|MathML Core 已通过 `math` 节点暴露。推荐顺序是先查 `edn-relay help --channel genui math`，再查 `math-fraction-demo`，最后发送 `:type |math` + `:expr` 的 Cirru EDN payload。")
              {} (:name |validation) (:title |Validation) (:text "|浏览器验证优先看 `chrome-devtools take_snapshot` 和 `chrome-devtools list_console_messages`；CLI 侧优先看 `status`、`help`、`skill` 是否和当前页面一致。局部编辑失败时，优先检查返回的 `ack false` 和对应 `:path`。")
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
        |build-saved-report-entry $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn build-saved-report-entry (relay renderer)
              let
                  channel $ :selected-channel relay
                  layout-dsl $ :layout-dsl renderer
                  layout-id $ :layout-id renderer
                  request-id $ :last-request renderer
                  saved-at $ .!toISOString (new js/Date)
                  source $ if
                    some? $ :layout-source renderer
                    :layout-source renderer
                    format-cirru-edn layout-dsl
                {} (:kind :saved-report) (:channel channel)
                  :title $ str (or channel |report) | / (or layout-id |snapshot)
                  :layout_id layout-id
                  :request_id request-id
                  :saved_at saved-at
                  :layout layout-dsl
                  :source source
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
                if (some? @*ws)
                  tag-match op
                    (:select-channel _) (sync-selected-channel! @*ws)
                    (:request-storage-list) (request-storage-list! @*ws)
                    (:save-current-report) (request-storage-save! @*ws)
                    (:load-stored-report name) (request-storage-load! @*ws name)
                    _ nil
                  , nil
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
                  source $ format-cirru-edn payload
                  layout-id $ str |layout- request-id
                try
                  let
                      layout $ -> payload validate-layout
                      ack-payload $ {} (:status :ok) (:layout_id layout-id)
                    do
                      dispatch! $ :: :genui-applied request-id layout-id layout payload source
                      send-genui-ack! ws request-id true ack-payload nil
                  fn (error)
                    let
                        message $ if
                          some? $ .-message error
                          .-message error
                          str error
                      do
                        dispatch! $ :: :genui-failed request-id message source
                        .!warn js/console "|[renderer] validation failed" error
                        send-genui-ack! ws request-id false nil message
          :examples $ []
        |handle-relay-message! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn handle-relay-message! (ws raw)
              let
                  frame $ parse-cirru-edn raw
                  kind $ protocol-name (:kind frame)
                  payload $ :payload frame
                  request $ parse-renderer-request payload
                  selected $ selected-relay-channel
                  pending-storage $ get-in @*reel ([] :store :renderer :storage-pending)
                  summary $ if (= kind |hello-ok) "|Relay connected"
                    if (= kind |channel-state) "|Channel list updated" $ if (= kind |warning)
                      or (:error frame) "|Relay warning"
                      if (= kind |error)
                        or (:error frame) "|Relay error"
                        if
                          and (= kind |ack) (some? pending-storage)
                            = (:id frame) (:request-id pending-storage)
                          str "|Storage " $ or (:op pending-storage) |request
                          if (= kind |event)
                            tag-match request
                              (:help _) "|Renderer help"
                              (:skill _) "|Renderer skill"
                              (:status) "|Renderer status"
                              (:snapshot path)
                                str "|Layout snapshot " $ layout-path-display path
                              (:layout path)
                                str "|Layout summary " $ layout-path-display path
                              (:node path)
                                str "|Layout node " $ layout-path-display path
                              (:patch path _)
                                str "|Layout patch " $ layout-path-display path
                              (:replace path _)
                                str "|Layout replace " $ layout-path-display path
                              _ "|Layout payload"
                            str "|Relay " kind
                do
                  dispatch! $ :: :record-relay-message
                    {} (:kind kind)
                      :channel $ :channel frame
                      :request-id $ :id frame
                      :matched? $ if (= kind |event)
                        and (some? selected)
                          = (:channel frame) selected
                        , true
                      :summary summary
                      :raw raw
                  if (= kind |hello-ok)
                    handle-channel-state! ws (:client_id frame) (:channels frame)
                    if (= kind |channel-state)
                      handle-channel-state! ws nil $ :channels frame
                      if (= kind |event)
                        if
                          and (some? selected)
                            = (:channel frame) selected
                          tag-match request
                            (:help _) (handle-renderer-event! ws frame)
                            (:skill _) (handle-renderer-event! ws frame)
                            (:status) (handle-renderer-event! ws frame)
                            (:snapshot _) (handle-renderer-event! ws frame)
                            (:layout _) (handle-renderer-event! ws frame)
                            (:node _) (handle-renderer-event! ws frame)
                            (:patch _ _) (handle-renderer-event! ws frame)
                            (:replace _ _) (handle-renderer-event! ws frame)
                            _ $ handle-genui-event! ws frame
                          do |ignored
                        if
                          and (= kind |ack) (some? pending-storage)
                            = (:id frame) (:request-id pending-storage)
                          handle-storage-ack! frame
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
                  request $ parse-renderer-request payload
                  relay $ get-in @*reel ([] :store :relay)
                  renderer $ get-in @*reel ([] :store :renderer)
                do (.!debug js/console "|[renderer] request" payload)
                  try
                    tag-match request
                      (:help topics)
                        let
                            response-payload $ config/build-help-payload topics
                          send-genui-ack! ws request-id true response-payload nil
                      (:skill topics)
                        send-genui-ack! ws request-id true (config/build-skill-payload topics) nil
                      (:status)
                        send-genui-ack! ws request-id true (config/build-status-payload relay renderer) nil
                      (:snapshot path)
                        if-let
                          layout-dsl $ :layout-dsl renderer
                          let
                              target-node $ layout-node-at-path layout-dsl path
                              response-payload $ {} (:status :ok) (:kind :snapshot)
                                :path $ layout-path-display path
                                :tree $ summarize-layout-node target-node path
                            send-genui-ack! ws request-id true response-payload nil
                          send-genui-ack! ws request-id false nil "|No layout loaded in renderer"
                      (:layout path)
                        if-let
                          layout-dsl $ :layout-dsl renderer
                          let
                              target-node $ layout-node-at-path layout-dsl path
                              response-payload $ {} (:status :ok) (:kind :layout)
                                :layout_id $ :layout-id renderer
                                :path $ layout-path-display path
                                :summary $ summarize-layout-node target-node path
                            send-genui-ack! ws request-id true response-payload nil
                          send-genui-ack! ws request-id false nil "|No layout loaded in renderer"
                      (:node path)
                        if-let
                          layout-dsl $ :layout-dsl renderer
                          let
                              target-node $ layout-node-at-path layout-dsl path
                              response-payload $ {} (:status :ok) (:kind :node)
                                :layout_id $ :layout-id renderer
                                :path $ layout-path-display path
                                :dsl target-node
                                :source $ format-cirru-edn target-node
                                :summary $ summarize-layout-node target-node path
                            send-genui-ack! ws request-id true response-payload nil
                          send-genui-ack! ws request-id false nil "|No layout loaded in renderer"
                      (:patch path changes)
                        if-let
                          layout-dsl $ :layout-dsl renderer
                          let
                              next-dsl $ merge-layout-node-at-path layout-dsl path changes
                              next-layout $ validate-layout next-dsl
                              next-source $ format-cirru-edn next-dsl
                              next-layout-id $ str |layout- request-id
                              response-payload $ {} (:status :ok) (:kind :patch) (:layout_id next-layout-id)
                                :path $ layout-path-display path
                                :dsl $ layout-node-at-path next-dsl path
                                :summary $ summarize-layout-node (layout-node-at-path next-dsl path) path
                            do
                              dispatch! $ :: :layout-mutated request-id next-layout-id next-layout next-dsl next-source
                              send-genui-ack! ws request-id true response-payload nil
                          send-genui-ack! ws request-id false nil "|No layout loaded in renderer"
                      (:replace path next-node)
                        if-let
                          layout-dsl $ :layout-dsl renderer
                          let
                              next-dsl $ replace-layout-node-at-path layout-dsl path next-node
                              next-layout $ validate-layout next-dsl
                              next-source $ format-cirru-edn next-dsl
                              next-layout-id $ str |layout- request-id
                              response-payload $ {} (:status :ok) (:kind :replace) (:layout_id next-layout-id)
                                :path $ layout-path-display path
                                :dsl $ layout-node-at-path next-dsl path
                                :summary $ summarize-layout-node (layout-node-at-path next-dsl path) path
                            do
                              dispatch! $ :: :layout-mutated request-id next-layout-id next-layout next-dsl next-source
                              send-genui-ack! ws request-id true response-payload nil
                          send-genui-ack! ws request-id false nil "|No layout loaded in renderer"
                      (:invalid) (send-genui-ack! ws request-id false nil "|Unsupported renderer request")
                    fn (error)
                      let
                          message $ if
                            some? $ .-message error
                            .-message error
                            str error
                        do (.!warn js/console "|[renderer] request failed" error) (send-genui-ack! ws request-id false nil message)
          :examples $ []
        |handle-storage-ack! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn handle-storage-ack! (frame)
              let
                  request-id $ :id frame
                  pending $ get-in @*reel ([] :store :renderer :storage-pending)
                when
                  and (some? pending)
                    = request-id $ :request-id pending
                  if (:ok frame)
                    try
                      let
                          payload $ :payload frame
                          kind $ protocol-name (:kind payload)
                        if (= kind |storage-list)
                          dispatch! $ :: :storage-listed request-id
                            if
                              list? $ :entries payload
                              :entries payload
                              []
                          if (= kind |storage-save)
                            do
                              dispatch! $ :: :storage-saved request-id payload
                              when (some? @*ws) (request-storage-list! @*ws)
                            if (= kind |storage-load)
                              let
                                  entry $ :entry payload
                                  layout-dsl $ :layout entry
                                  source $ or (:source payload) (:source entry) (format-cirru-edn layout-dsl)
                                  layout-id $ or (:layout_id entry)
                                    str |saved- $ :name payload
                                  layout $ validate-layout layout-dsl
                                dispatch! $ :: :storage-loaded request-id payload layout-id layout layout-dsl source
                              dispatch! $ :: :storage-failed request-id "|Unsupported storage ack payload"
                      fn (error)
                        let
                            message $ if
                              some? $ .-message error
                              .-message error
                              str error
                          dispatch! $ :: :storage-failed request-id message
                    dispatch! $ :: :storage-failed request-id
                      or (:error frame) "|Storage request failed"
          :examples $ []
        |internal-storage-channel $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote (def internal-storage-channel |__relay_store__)
          :examples $ []
        |layout-node-at-path $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn layout-node-at-path (node path)
              if (empty? path) node $ let
                  children $ or (:children node) ([])
                  step $ first path
                  child $ pick-layout-child children step
                if
                  not $ list? children
                  raise $ str "|Path " (layout-path-display path) "| requires a parent with :children"
                  if (nil? child)
                    raise $ str "|Missing layout node at path " (layout-path-display path)
                    recur child $ rest path
          :examples $ []
        |layout-path-display $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn layout-path-display (path)
              if (empty? path) |root $ layout-path-display-iter path |
          :examples $ []
        |layout-path-display-iter $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn layout-path-display-iter (path acc)
              if (empty? path) acc $ let
                  step $ str (first path)
                recur (rest path)
                  if (= acc |) step $ str acc |. step
          :examples $ []
        |layout-path-segment-pattern $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def layout-path-segment-pattern $ new js/RegExp "|^([0-9]+)$"
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
        |merge-layout-node-at-path $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn merge-layout-node-at-path (node path changes)
              if
                not $ map? changes
                raise "|Patch request expects map field :changes"
                if (empty? path) (merge node changes)
                  let
                      children $ or (:children node) ([])
                      step $ first path
                    if
                      not $ list? children
                      raise $ str "|Path " (layout-path-display path) "| requires a parent with :children"
                      if
                        nil? $ pick-layout-child children step
                        raise $ str "|Missing layout node at path " (layout-path-display path)
                        assoc node :children $ -> children .to-list
                          map-indexed $ fn (idx child)
                            if
                              = (inc idx) step
                              merge-layout-node-at-path child (rest path) changes
                              , child
          :examples $ []
        |mount-target $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def mount-target $ js/document.querySelector |.app
          :examples $ []
        |normalize-layout-path $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn normalize-layout-path (path)
              if (nil? path) ([])
                if (number? path)
                  let
                      segment $ parse-layout-path-segment path
                    if (some? segment) ([] segment) nil
                  if (list? path)
                    foldl path ([])
                      fn (acc item)
                        if (nil? acc) nil $ let
                            segment $ parse-layout-path-segment item
                          if (some? segment) (append acc segment) nil
                    if
                      or (string? path) (tag? path)
                      let
                          raw $ turn-string path
                        if
                          or (= raw |) (= raw |root)
                          []
                          foldl (split raw |.) ([])
                            fn (acc item)
                              if (nil? acc) nil $ let
                                  segment $ parse-layout-path-segment item
                                if (some? segment) (append acc segment) nil
                      , nil
          :examples $ []
        |normalize-renderer-topics $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn normalize-renderer-topics (topics)
              if (list? topics)
                foldl topics ([])
                  fn (acc item)
                    if
                      or (string? item) (tag? item)
                      append acc $ turn-string item
                      , acc
                []
          :examples $ []
        |parse-layout-path-segment $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn parse-layout-path-segment (item)
              if (number? item)
                if (> item 0) item nil
                if
                  or (string? item) (tag? item)
                  let
                      text $ turn-string item
                    if
                      some? $ .!match text layout-path-segment-pattern
                      js/parseInt text 10
                      , nil
                  , nil
          :examples $ []
        |parse-renderer-request $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn parse-renderer-request (payload)
              if (tuple? payload)
                tag-match payload
                  (:help)
                    :: :help $ []
                  (:help topics)
                    :: :help $ normalize-renderer-topics topics
                  (:skill)
                    :: :skill $ []
                  (:skill topics)
                    :: :skill $ normalize-renderer-topics topics
                  (:status) (:: :status)
                  (:snapshot)
                    :: :snapshot $ []
                  (:snapshot path)
                    if-let
                      normalized $ normalize-layout-path path
                      :: :snapshot normalized
                      :: :invalid
                  (:layout)
                    :: :layout $ []
                  (:layout path)
                    if-let
                      normalized $ normalize-layout-path path
                      :: :layout normalized
                      :: :invalid
                  (:node path)
                    if-let
                      normalized $ normalize-layout-path path
                      :: :node normalized
                      :: :invalid
                  (:patch path changes)
                    if-let
                      normalized $ normalize-layout-path path
                      :: :patch normalized changes
                      :: :invalid
                  (:replace path next-node)
                    if-let
                      normalized $ normalize-layout-path path
                      :: :replace normalized next-node
                      :: :invalid
                  _ $ :: :invalid
                if (map? payload)
                  let
                      op-name $ protocol-name (:op payload)
                      topics $ normalize-renderer-topics (:topics payload)
                    case-default op-name (:: :invalid)
                      |help $ :: :help topics
                      |skill $ :: :skill topics
                      |status $ :: :status
                      |snapshot $ let
                          normalized $ normalize-layout-path (:path payload)
                        if (some? normalized) (:: :snapshot normalized) (:: :invalid)
                      |layout $ let
                          normalized $ normalize-layout-path (:path payload)
                        if (some? normalized) (:: :layout normalized) (:: :invalid)
                      |node $ let
                          normalized $ normalize-layout-path (:path payload)
                        if (some? normalized) (:: :node normalized) (:: :invalid)
                      |patch $ let
                          normalized $ normalize-layout-path (:path payload)
                        if (some? normalized) (:: :patch normalized $ :changes payload) (:: :invalid)
                      |replace $ let
                          normalized $ normalize-layout-path (:path payload)
                        if
                          some? normalized
                          :: :replace normalized $ or (:node payload) (:dsl payload)
                          :: :invalid
                  :: :invalid
          :examples $ []
        |persist-storage! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn persist-storage! ()
              println "|Saved at" $ .!toISOString (new js/Date)
              js/localStorage.setItem (:storage-key config/site)
                format-cirru-edn $ :store @*reel
          :examples $ []
        |pick-layout-child $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn pick-layout-child (children position)
              if
                not $ list? children
                , nil $ if
                  not $ > position 0
                  , nil
                    if (empty? children) nil $ if (= position 1) (first children)
                      recur (rest children) (dec position)
          :examples $ []
        |protocol-name $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn protocol-name (x)
              if
                or (string? x) (tag? x)
                turn-string x
                , nil
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
        |replace-layout-node-at-path $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn replace-layout-node-at-path (node path next-node)
              if (empty? path) next-node $ let
                  children $ or (:children node) ([])
                  step $ first path
                if
                  not $ list? children
                  raise $ str "|Path " (layout-path-display path) "| requires a parent with :children"
                  if
                    nil? $ pick-layout-child children step
                    raise $ str "|Missing layout node at path " (layout-path-display path)
                    assoc node :children $ -> children .to-list
                      map-indexed $ fn (idx child)
                        if
                          = (inc idx) step
                          replace-layout-node-at-path child (rest path) next-node
                          , child
          :examples $ []
        |request-storage-list! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn request-storage-list! (ws)
              if-let
                channel $ selected-relay-channel
                let
                    request-id $ str |storage-list- (.!now js/Date)
                  do
                    dispatch! $ :: :storage-pending request-id |list
                    send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                      :payload $ {} (:op :list) (:channel channel)
                dispatch! $ :: :storage-failed nil "|Select a channel before browsing saved reports"
          :examples $ []
        |request-storage-load! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn request-storage-load! (ws name)
              if-let
                channel $ selected-relay-channel
                let
                    request-id $ str |storage-load- (.!now js/Date)
                  do
                    dispatch! $ :: :storage-pending request-id |load
                    send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                      :payload $ {} (:op :load) (:channel channel) (:name name)
                dispatch! $ :: :storage-failed nil "|Select a channel before loading saved reports"
          :examples $ []
        |request-storage-save! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn request-storage-save! (ws)
              let
                  relay $ get-in @*reel ([] :store :relay)
                  renderer $ get-in @*reel ([] :store :renderer)
                if
                  and
                    some? $ :selected-channel relay
                    some? $ :layout-dsl renderer
                  let
                      request-id $ str |storage-save- (.!now js/Date)
                      entry $ build-saved-report-entry relay renderer
                      file-name $ str
                        or (:selected-channel relay) |report
                        , |-
                          or (:layout-id renderer) (:last-request renderer) |snapshot
                    do
                      dispatch! $ :: :storage-pending request-id |save
                      send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                        :payload $ {} (:op :save)
                          :channel $ :selected-channel relay
                          :name file-name
                          :entry entry
                  dispatch! $ :: :storage-failed nil "|A validated layout is required before saving a report"
          :examples $ []
        |selected-relay-channel $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn selected-relay-channel () $ get-in @*reel ([] :store :relay :selected-channel)
          :examples $ []
        |send-genui-ack! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn send-genui-ack! (ws request-id ok? payload error-message)
              send-relay-frame! ws $ {} (:kind :ack) (:id request-id) (:ok ok?) (:payload payload) (:error error-message)
          :examples $ []
        |send-relay-frame! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn send-relay-frame! (ws frame)
              .!send ws $ format-cirru-edn frame
          :examples $ []
        |summarize-layout-node $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn summarize-layout-node (node path)
              let
                  node-type $ :type node
                  children $ if
                    list? $ :children node
                    :children node
                    []
                  base $ {}
                    :path $ layout-path-display path
                    :type node-type
                    :child-count $ count children
                  meta $ case-default node-type ({})
                    |card $ if
                      string? $ :text node
                      {} $ :title (:text node)
                      {}
                    |text $ if
                      string? $ :text node
                      {} $ :text
                        first $ split-lines (:text node)
                      {}
                    |badge $ if
                      string? $ :text node
                      {} $ :text (:text node)
                      {}
                    |button $ if
                      string? $ :text node
                      {} $ :text (:text node)
                      {}
                    |input $ {}
                      :name $ :name node
                      :placeholder $ :placeholder node
                    |markdown $ {}
                      :lines $ count
                        split-lines $ or (:text node) |
                    |mermaid $ {}
                      :lines $ count
                        split-lines $ or (:text node) |
                    |chart $ {}
                      :kind $ or (:kind node) |bar
                      :title $ or (:title node) |
                      :series-count $ count
                        or (:series node) ([])
                    |math $ {}
                      :display $ or (:display node) |inline
                      :expr-tag $ first
                        or (:expr node) ([])
                merge base $ if
                  > (count children) 0
                  assoc meta :children $ -> children .to-list
                    map-indexed $ fn (idx child)
                      summarize-layout-node child $ append path (inc idx)
                  , meta
          :examples $ []
        |sync-selected-channel! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn sync-selected-channel! (ws)
              let
                  client-id $ get-in @*reel ([] :store :relay :client-id)
                  selected $ selected-relay-channel
                  channels $ if (some? selected) ([] selected internal-storage-channel) ([] internal-storage-channel)
                send-relay-frame! ws $ {} (:kind :hello) (:role :receiver) (:client_id client-id) (:channels channels)
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
              :renderer $ {} (:layout nil) (:layout-dsl nil) (:layout-id nil) (:layout-source |) (:last-request nil) (:last-error nil)
                :history $ []
                :selected-history nil
                :drawer-view |history
                :storage-status |idle
                :storage-error nil
                :storage-pending nil
                :storage-entries $ []
                :selected-storage nil
                :workspace-entry nil
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
                    update :renderer $ fn (renderer)
                      -> (or renderer {}) (assoc :layout nil) (assoc :layout-dsl nil) (assoc :layout-id nil) (assoc :layout-source |) (assoc :last-request nil) (assoc :last-error nil) (assoc :storage-status |idle) (assoc :storage-error nil) (assoc :storage-pending nil)
                        assoc :storage-entries $ []
                        assoc :selected-storage nil
                        assoc :workspace-entry nil
                (:relay-status status message)
                  -> store
                    assoc-in ([] :relay :status) status
                    assoc-in ([] :relay :last-error) message
                (:record-relay-message entry)
                  update store :renderer $ fn (renderer)
                    let
                        prev-renderer $ or renderer {}
                        prev-history $ if
                          list? $ :history prev-renderer
                          :history prev-renderer
                          []
                      -> prev-renderer
                        assoc :history $ append prev-history entry
                        assoc :selected-history entry
                (:select-history entry)
                  update store :renderer $ fn (renderer)
                    assoc (or renderer {}) :selected-history entry
                (:open-history-drawer)
                  update store :renderer $ fn (renderer)
                    assoc (or renderer {}) :drawer-view |history
                (:open-library-drawer)
                  update store :renderer $ fn (renderer)
                    assoc (or renderer {}) :drawer-view |library
                (:request-storage-list) store
                (:save-current-report) store
                (:load-stored-report _) store
                (:load-workspace-report)
                  update store :renderer $ fn (renderer)
                    let
                        prev-renderer $ or renderer {}
                        entry $ :workspace-entry prev-renderer
                      if-let (current-entry entry)
                        -> prev-renderer (assoc :selected-storage current-entry)
                          assoc :layout $ :layout-data current-entry
                          assoc :layout-dsl $ :layout-dsl current-entry
                          assoc :layout-id $ :layout_id current-entry
                          assoc :layout-source $ :source current-entry
                          assoc :last-request $ :request_id current-entry
                          assoc :last-error nil
                          assoc :storage-status |workspace
                          assoc :storage-error nil
                        , prev-renderer
                (:storage-pending request-id op-name)
                  update store :renderer $ fn (renderer)
                    -> (or renderer {})
                      assoc :storage-pending $ {} (:request-id request-id) (:op op-name)
                      assoc :storage-status |working
                      assoc :storage-error nil
                (:storage-saved request-id entry)
                  update store :renderer $ fn (renderer)
                    -> (or renderer {}) (assoc :storage-pending nil) (assoc :storage-status |saved) (assoc :storage-error nil) (assoc :selected-storage entry)
                (:storage-listed request-id entries)
                  update store :renderer $ fn (renderer)
                    -> (or renderer {}) (assoc :storage-pending nil) (assoc :storage-status |ready) (assoc :storage-error nil) (assoc :storage-entries entries)
                (:storage-loaded request-id entry layout-id layout layout-dsl source)
                  update store :renderer $ fn (renderer)
                    -> (or renderer {}) (assoc :storage-pending nil) (assoc :storage-status |loaded) (assoc :storage-error nil) (assoc :selected-storage entry) (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil)
                (:storage-failed request-id message)
                  update store :renderer $ fn (renderer)
                    -> (or renderer {}) (assoc :storage-pending nil) (assoc :storage-status |error) (assoc :storage-error message)
                (:genui-applied request-id layout-id layout layout-dsl source)
                  let
                      entry $ ->
                        {} $ :kind :workspace-report
                        assoc :channel $ get-in store ([] :relay :selected-channel)
                        assoc :name $ str
                          or
                            get-in store $ [] :relay :selected-channel
                            , |workspace
                          , "| / current workspace"
                        assoc :path "|Local workspace snapshot. Not saved in library."
                        assoc :layout_id layout-id
                        assoc :request_id request-id
                        assoc :layout-data layout
                        assoc :layout-dsl layout-dsl
                        assoc :source source
                    update store :renderer $ fn (renderer)
                      -> (or renderer {}) (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil) (assoc :workspace-entry entry) (assoc :selected-storage entry) (assoc :storage-status |workspace) (assoc :storage-error nil)
                (:genui-failed request-id message source)
                  update store :renderer $ fn (renderer)
                    -> (or renderer {}) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error message)
                (:layout-mutated request-id layout-id layout layout-dsl source)
                  let
                      entry $ ->
                        {} $ :kind :workspace-report
                        assoc :channel $ get-in store ([] :relay :selected-channel)
                        assoc :name $ str
                          or
                            get-in store $ [] :relay :selected-channel
                            , |workspace
                          , "| / current workspace"
                        assoc :path "|Local workspace snapshot. Not saved in library."
                        assoc :layout_id layout-id
                        assoc :request_id request-id
                        assoc :layout-data layout
                        assoc :layout-dsl layout-dsl
                        assoc :source source
                    update store :renderer $ fn (renderer)
                      -> (or renderer {}) (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil) (assoc :workspace-entry entry) (assoc :selected-storage entry) (assoc :storage-status |workspace) (assoc :storage-error nil)
                _ $ do (eprintln "|unknown op:" op) store
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns app.updater $ :require
            respo.cursor :refer $ update-states
