
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |alerts.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op 'app.schema/DispatchOp
  :files $ {}
    'app.comp.container $ %{} 'FileEntry
      :defs $ {}
        '*mermaid-ready $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *mermaid-ready false
          :examples $ []
          :schema $ quote $ Ref Bool
        '*rendered-svgs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *rendered-svgs ({})
          :examples $ []
          :schema $ quote $ Ref (Map String MermaidCache)
        'ChartDatum $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ChartDatum (:label String) (:value Number)
          :examples $ []
          :schema $ quote StructDef
        'ChartKind $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum ChartKind (:bar) (:line) (:pie) (:scatter)
          :examples $ []
          :schema $ quote EnumDef
        'ChartOptionValue $ %{} 'CodeEntry
          :doc "|Closed value family emitted by the ECharts option builder."
          :code $ quote $ defunion ChartOptionValue String Number Bool (List ChartOptionValue) (Map Tag ChartOptionValue)
          :examples $ []
          :schema $ quote UnionDef
        'EChartHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait EChartHost
            .set-option! $ Fn app.comp.container/EChartHost JsObject Bool $ -> Unit
            .dispose! $ Fn app.comp.container/EChartHost $ -> Unit
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} (:dispose! |dispose) (:set-option! |setOption)
          :schema $ quote Trait
        'LayoutNode $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum LayoutNode
            :column $ List app.comp.container/LayoutNode
            :row $ List app.comp.container/LayoutNode
            :card (Option String) (List app.comp.container/LayoutNode)
            :text String
            :badge String
            :divider
            :button String
            :input (Option Dynamic) (Option Dynamic) (Option Dynamic)
            :markdown String
            :mermaid String
            :chart app.comp.container/ChartKind (Option String) (List app.comp.container/ChartDatum)
            :math app.comp.container/MathExpr String
          :examples $ []
          :schema $ quote EnumDef
        'MathChild $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defunion MathChild String Number app.comp.container/MathExpr
          :examples $ []
          :schema $ quote UnionDef
        'MathElementHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait MathElementHost (:inner-html 'String)
            .set-attribute! $ Fn app.comp.container/MathElementHost String String $ -> Unit
            .append-child! $ Fn app.comp.container/MathElementHost JsObject $ -> JsObject
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} (:append-child! |appendChild) (:inner-html |innerHTML) (:set-attribute! |setAttribute)
            :writable $ #{} :inner-html
          :schema $ quote Trait
        'MathExpr $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct MathExpr (:tag String)
            :children $ List app.comp.container/MathChild
          :examples $ []
          :schema $ quote StructDef
        'MermaidCache $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum MermaidCache (:rendering) (:failed) (:ready String)
          :examples $ []
          :schema $ quote EnumDef
        'MermaidHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait MermaidHost
            .initialize! $ Fn app.comp.container/MermaidHost JsObject $ -> Unit
            .render $ Fn app.comp.container/MermaidHost String String $ -> js-ffi.shared/PromiseHost
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} $ :initialize! |initialize
          :schema $ quote Trait
        'MermaidPayload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct MermaidPayload (:empty? Bool) (:source String) (:graph-id String)
          :examples $ []
          :schema $ quote StructDef
        'MermaidResultHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait MermaidResultHost (:svg 'String)
            :bind-functions $ JsNullish $ Fn js-ffi.browser/DomElementHost (-> Unit)
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} $ :bind-functions |bindFunctions
          :schema $ quote Trait
        'append-mathml-child! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn append-mathml-child! (el child path)
            match child
              (String text)
                el .append-child! $ contract/expect-object |append-mathml-child! $ js/document.createTextNode text
              (Number value)
                el .append-child! $ contract/expect-object |append-mathml-child! $ js/document.createTextNode (str value)
              (app.comp.container/MathExpr nested)
                el .append-child! $ contract/expect-object |append-mathml-child! $ build-mathml-element nested path
            , &unit
          :examples $ []
          :schema $ quote $ Fn MathElementHost MathChild String (-> Unit) (:features :js-ffi)
        'build-echarts-option $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-echarts-option (points kind title)
            let
                series-type $ match kind
                  (:line) |line
                  (:pie) |pie
                  (:scatter) |scatter
                  (:bar) |bar
                series-data $ if (= series-type |pie)
                  map points $ fn (point)
                    hint-fn $ Fn ChartDatum $ -> ChartOptionValue
                    {}
                      :name $ :label point
                      :value $ :value point
                  map points $ fn (point)
                    hint-fn $ Fn ChartDatum $ -> ChartOptionValue
                    :value point
                option $ assert-type
                  {} (:animation false)
                    :tooltip $ {}
                    :grid $ {} (:left 48) (:right 24) (:top 72) (:bottom 72) (:containLabel true)
                    :series $ [] $ {} (:type series-type) (:data series-data)
                  Map Tag ChartOptionValue
                with-title $ match title
                  (:none) option
                  (:some text)
                    .merge option $ assert-type
                      {} $ :title $ {} (:text text)
                      Map Tag ChartOptionValue
              if (= series-type |pie) with-title $ .merge with-title $ assert-type
                {}
                  :xAxis $ {} (:type |category)
                    :data $ map points $ fn (point)
                      hint-fn $ Fn ChartDatum $ -> ChartOptionValue
                      :label point
                    :axisLabel $ {} (:interval 0) (:rotate 20) (:hideOverlap false)
                  :yAxis $ {} $ :type |value
                Map Tag ChartOptionValue
          :examples $ []
          :schema $ quote $ Fn (List ChartDatum) ChartKind (Option String)
            -> $ Map Tag ChartOptionValue
        'build-mathml-element $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-mathml-element (expr path)
            let
                tag-name $ :tag expr
                el $ js-cast (browser/create-element-ns mathml-namespace tag-name) 'MathElementHost
              .foldl (:children expr) &unit $ fn (acc child)
                hint-fn $ Fn Unit MathChild $ -> Unit
                append-mathml-child! el child $ str path |/ tag-name
              , el
          :examples $ []
          :schema $ quote $ Fn MathExpr String (-> MathElementHost) (:features :js-ffi)
        'build-mathml-root $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-mathml-root (expr display)
            let
                root $ js-cast (browser/create-element-ns mathml-namespace |math) 'MathElementHost
              root .set-attribute! |display $ math-display-value display
              root .append-child! $ contract/expect-object |build-mathml-root $ build-mathml-element expr |math
              , root
          :examples $ []
          :schema $ quote $ Fn MathExpr String (-> MathElementHost) (:features :js-ffi)
        'build-mermaid-render-payload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-mermaid-render-payload (text)
            if
              = (trim text) |
              &%{} MermaidPayload :empty? true :source | :graph-id |
              &%{} MermaidPayload :empty? false :source text :graph-id $ str |mermaid- (.len text) |- $ .len (split-lines text)
          :examples $ []
          :schema $ quote $ Fn String (-> MermaidPayload)
        'comp-chart-block $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-chart-block (series kind title)
            let
                option $ build-echarts-option series kind title
              [] (effect-echarts option)
                div $ {} (:class-name |echarts-host)
                  :style $ {} (:width |100%) (:height |300px)
          :examples $ []
          :schema $ quote $ Fn (List ChartDatum) ChartKind (Option String) (-> respo.schema/Component) (:features :js-ffi)
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (reel)
            let
                store $ decode-map-as
                  .unwrap $ get reel :store
                  Map Tag Dynamic
                states $ decode-map-as
                  .unwrap $ get store :states
                  Map Tag Dynamic
                relay $ decode-map-as
                  field-or store :relay $ {}
                  Map Tag Dynamic
                renderer $ decode-map-as
                  field-or store :renderer $ {}
                  Map Tag Dynamic
                drawer-open? $ .unwrap-or
                  get-in states $ [] :drawer :data :show?
                  , false
                selected-channel $ decode-map-as
                  .and-then (get relay :selected-channel) present-option
                  Option String
                channels $ match
                  data-view $ field-or relay :channels $ []
                  (:list items)
                    decode-map-as items $ List String
                  _ $ []
                history $ match
                  data-view $ field-or renderer :history $ []
                  (:list items) items
                  _ $ []
                selected-history $ decode-map-as
                  .and-then (get renderer :selected-history) present-option
                  Option $ Map Tag Dynamic
                storage-status $ field-or renderer :storage-status |idle
                storage-error $ decode-map-as
                  .and-then (get renderer :storage-error) present-option
                  Option String
                storage-entries $ match
                  data-view $ field-or renderer :storage-entries $ []
                  (:list items) items
                  _ $ []
                selected-storage $ decode-map-as
                  .and-then (get renderer :selected-storage) present-option
                  Option $ Map Tag Dynamic
                workspace-entry $ decode-map-as
                  .and-then (get renderer :workspace-entry) present-option
                  Option $ Map Tag Dynamic
                detail-status $ if (storage-kind? selected-storage :workspace-report) |workspace storage-status
                drawer-view $ field-or renderer :drawer-view |history
                drawer-plugin $ use-drawer (>> states :drawer)
                  {}
                    :style $ {} (:width 820) (:min-width 0) (:max-width "|calc(100vw - 24px)") (:padding "|12px 12px 14px") (:gap 12) (:background-color |#f7f7f3) (:border-left "|1px solid #d7d7cf") (:box-shadow "|-12px 0 28px hsla(210, 8%, 18%, 0.12)") (:overflow |auto)
                    :container-style $ if drawer-open?
                      {} (:position :fixed) (:top 0) (:right 0) (:bottom 0) (:left 0) (:z-index |40)
                      {}
                    :backdrop-style $ {} (:background-color "|hsla(210, 10%, 18%, 0.08)") (:backdrop-filter "|blur(8px)")
                    :render $ fn (on-close)
                      div
                        {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 12)
                        div
                          {} $ :style $ {} (:display |flex) (:justify-content |space-between) (:align-items |center) (:gap 10) (:flex-wrap |wrap)
                          div
                            {} $ :style $ {} (:display |flex) (:align-items |center) (:gap 8) (:flex-wrap |wrap)
                            div
                              {} $ :style $ {} (:font-size 15) (:font-weight |700) (:color |#1f2933)
                              <> $ if (= drawer-view |library) |Library |History
                            div
                              {} $ :style $ {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                              <> $ str "|Messages: " $ .len history
                            if (.some? selected-channel)
                              Some $ div
                                {} $ :style $ {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                <> $ str "|Channel: " $ .unwrap selected-channel
                              , None
                            div
                              {} $ :style $ {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                              <> $ str "|Reports: " $ .len storage-entries
                          button $ {} (:class-name css/button) (:inner-text |Close)
                            :style $ {} (:padding "|5px 9px") (:font-size 11)
                            :on-click $ fn (e d!) (on-close d!)
                        div
                          {} $ :style $ {} (:display |flex) (:align-items |stretch) (:gap 12) (:flex-wrap |wrap)
                          div
                            {} $ :style $ {} (:width 290) (:max-width |100%) (:display |flex) (:flex-direction |column) (:gap 8)
                            div
                              {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#4b5563)
                              <> $ if (= drawer-view |library) "|Library Items" |Messages
                            if (= drawer-view |library)
                              div
                                {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 6) (:max-height "|calc(100vh - 180px)") (:overflow |auto)
                                match workspace-entry
                                  (:some item)
                                    Some $ let
                                        active? $ storage-kind? selected-storage :workspace-report
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
                                          {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                          <> $ decode-map-as (field-or item :name "|Current workspace") 'String
                                        div
                                          {} $ :style $ {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                          <> $ decode-map-as (field-or item :path |) 'String
                                  (:none) None
                                if
                                  > (.len storage-entries) 0
                                  keyed->
                                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 6)
                                    -> storage-entries .to-list $ map-indexed $ fn (idx item)
                                      let
                                          active? $ match selected-storage
                                            (:some current)
                                              if
                                                = (field current :kind) (Some :workspace-report)
                                                , false $ = (field item :name) (field current :name)
                                            (:none) false
                                        keyed-element idx $ div
                                          {}
                                            :style $ {} (:padding "|8px 10px") (:border-radius 12)
                                              :border $ if active? "|1px solid #8a8f98" "|1px solid #d7d7cf"
                                              :background-color $ if active? |#eef1f4 |#ffffff
                                              :cursor |pointer
                                              :display |flex
                                              :flex-direction |column
                                              :gap 4
                                            :on-click $ fn (e d!)
                                              d! $ :: :load-stored-report $ .unwrap (get item :name)
                                          div
                                            {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                            <> $ decode-map-as (field-or item :name "|Saved report") 'String
                                          div
                                            {} $ :style $ {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                            <> $ decode-map-as (field-or item :path |) 'String
                                  div
                                    {} $ :style $ {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|No saved reports for current channel yet."
                              if
                                > (.len history) 0
                                keyed->
                                  {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 6) (:max-height "|calc(100vh - 180px)") (:overflow |auto)
                                  -> history .to-list $ map-indexed $ fn (idx item)
                                    let
                                        active? $ match selected-history
                                          (:some current)
                                            = (field item :raw) (field current :raw)
                                          (:none) false
                                        meta-channel $ field-or item :channel |session
                                        meta-request $ field-or item :request-id |-
                                      keyed-element idx $ div
                                        {}
                                          :style $ {} (:padding "|8px 10px") (:border-radius 12)
                                            :border $ if active? "|1px solid #8a8f98" "|1px solid #d7d7cf"
                                            :background-color $ if active? |#eef1f4 |#ffffff
                                            :cursor |pointer
                                            :display |flex
                                            :flex-direction |column
                                            :gap 4
                                            :opacity $ if (field-or item :matched? false) |1 |0.72
                                          :on-click $ fn (e d!)
                                            d! $ :: :select-history item
                                        div
                                          {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                          <> $ decode-map-as (field-or item :summary |Message) 'String
                                        div
                                          {} $ :style $ {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                          <> $ str (field-or item :kind |unknown) "| / " meta-channel "| / " meta-request
                                div
                                  {} $ :style $ {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                  <> "|No relay messages yet."
                          div
                            {} $ :style $ {} (:flex |1) (:min-width 280) (:display |flex) (:flex-direction |column) (:gap 8)
                            div
                              {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#4b5563)
                              <> |Detail
                            if (= drawer-view |library)
                              match selected-storage
                                (:some item)
                                  div
                                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 8)
                                    div
                                      {} $ :style $ {} (:font-size 14) (:font-weight |700) (:color |#1f2933)
                                      <> $ decode-map-as (field-or item :name "|Saved report") 'String
                                    div
                                      {} $ :style $ {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                                      div
                                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Status: " detail-status
                                      if (.some? selected-channel)
                                        Some $ div
                                          {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                          <> $ str "|Channel: " $ .unwrap selected-channel
                                        , None
                                    textarea $ {}
                                      :value $ format-cirru-edn $ {}
                                        :name $ field-or item :name |-
                                        :path $ field-or item :path |-
                                        :status detail-status
                                      :read-only true
                                      :spell-check false
                                      :placeholder "|Library item detail"
                                      :style $ {} (:width |100%) (:min-height "|calc(100vh - 320px)") (:padding 12) (:box-sizing |border-box) (:border-radius 14) (:border "|1px solid #d7d7cf") (:background-color |#ffffff) (:font-family |Monaco) (:font-size 12) (:line-height |1.6) (:resize |vertical)
                                (:none)
                                  div
                                    {} $ :style $ {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|Click the current workspace snapshot or a saved report to load it into the preview."
                              match selected-history
                                (:some item)
                                  div
                                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 8)
                                    div
                                      {} $ :style $ {} (:font-size 14) (:font-weight |700) (:color |#1f2933)
                                      <> $ decode-map-as (field-or item :summary |Message) 'String
                                    div
                                      {} $ :style $ {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                                      div
                                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Kind: " $ field-or item :kind |unknown
                                      div
                                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Channel: " $ field-or item :channel |session
                                      div
                                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Request: " $ field-or item :request-id |-
                                    if (field-or item :matched? false)
                                      div $ {}
                                      div
                                        {} $ :style $ {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#f4f4f1) (:border "|1px solid #deded8") (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                        <> "|This message did not match the current channel filter."
                                    textarea $ {}
                                      :value $ field-or item :raw |
                                      :read-only true
                                      :spell-check false
                                      :placeholder "|Relay frame detail"
                                      :style $ {} (:width |100%) (:min-height "|calc(100vh - 320px)") (:padding 12) (:box-sizing |border-box) (:border-radius 14) (:border "|1px solid #d7d7cf") (:background-color |#ffffff) (:font-family |Monaco) (:font-size 12) (:line-height |1.6) (:resize |vertical)
                                (:none)
                                  div
                                    {} $ :style $ {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|Click a message to inspect its raw relay frame."
                        if dev?
                          Some $ comp-reel (>> states :reel) reel $ {}
                          , None
                help-alert $ use-alert (>> states :help)
                  {} $ :text "|Use History to inspect recent relay frames and the raw Cirru EDN being rendered."
              effect-page-title selected-channel
              div
                {} $ :style $ {} (:min-height |100vh) (:padding 12) (:box-sizing |border-box) (:background-color |#efefeb) (:color |#1f2933) (:font-family |Avenir)
                div
                  {} $ :style $ {} (:display |flex) (:justify-content |space-between) (:align-items |center) (:gap 8) (:padding "|6px 8px") (:border-radius 12) (:background-color |#fbfbf8) (:border "|1px solid #d7d7cf") (:flex-wrap |wrap)
                  div
                    {} $ :style $ {} (:display |flex) (:align-items |center) (:gap 6) (:flex-wrap |wrap)
                    div
                      {} $ :style $ {} (:font-size 15) (:font-weight |700) (:line-height |1)
                      <> "|EDN Renderer"
                    div
                      {} $ :style $ {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                      if (.some? selected-channel)
                        <> $ str "|Channel: " $ .unwrap selected-channel
                        <> "|No channel"
                  div
                    {} $ :style $ {} (:display |flex) (:gap 6) (:flex-wrap |wrap) (:align-items |center) (:justify-content |flex-end)
                    div
                      {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#f4f4f1) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                      <> $ str "|Relay: " $ field-or relay :status |idle
                    div
                      {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#f4f4f1) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                      if (field-is? renderer :layout-id non-nil?) (<> |Ready) (<> |Waiting)
                    button $ {} (:class-name css/button)
                      :inner-text $ str "|History " $ .len history
                      :style $ {} (:padding "|5px 8px") (:font-size 11)
                      :on-click $ fn (e d!)
                        hint-fn $ Fn respo.schema/RespoEvent
                          Fn AnyEnum $ -> Unit
                          -> Unit
                        d! $ :: :open-history-drawer
                        .show drawer-plugin d!
                        , &unit
                    button $ {} (:class-name css/button) (:inner-text |Library)
                      :disabled $ .none? selected-channel
                      :style $ {} (:padding "|5px 8px") (:font-size 11)
                      :on-click $ fn (e d!)
                        hint-fn $ Fn respo.schema/RespoEvent
                          Fn AnyEnum $ -> Unit
                          -> Unit
                        d! $ :: :open-library-drawer
                        .show drawer-plugin d!
                        d! $ :: :request-storage-list
                        , &unit
                    button $ {} (:class-name css/button) (:inner-text |Save)
                      :disabled $ not $ field-is? renderer :layout-dsl non-nil?
                      :style $ {} (:padding "|5px 8px") (:font-size 11)
                      :on-click $ fn (e d!)
                        d! $ :: :save-current-report
                    button $ {} (:class-name css/button) (:inner-text |Tips)
                      :style $ {} (:padding "|5px 8px") (:font-size 11)
                      :on-click $ fn (e d!)
                        hint-fn $ Fn respo.schema/RespoEvent
                          Fn AnyEnum $ -> Unit
                          -> Unit
                        .show help-alert d! None
                        , &unit
                match
                  decode-map-as
                    .and-then (get relay :last-error) present-option
                    Option String
                  (:some relay-error)
                    Some $ div
                      {} $ :style $ {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff1ec) (:border "|1px solid #f0c4b4") (:font-size 12) (:line-height |1.5) (:color |#a23f1a) (:margin-top 8)
                      <> $ str "|Relay error: " relay-error
                  (:none) None
                match
                  decode-map-as
                    .and-then (get renderer :last-error) present-option
                    Option String
                  (:some render-error)
                    Some $ div
                      {} $ :style $ {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff1ec) (:border "|1px solid #f0c4b4") (:font-size 12) (:line-height |1.5) (:color |#a23f1a) (:margin-top 8)
                      <> $ str "|Validation error: " render-error
                  (:none) None
                match storage-error
                  (:some current-storage-error)
                    Some $ div
                      {} $ :style $ {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff7e9) (:border "|1px solid #e8c48f") (:font-size 12) (:line-height |1.5) (:color |#8a541d) (:margin-top 8)
                      <> $ str "|Storage error: " current-storage-error
                  (:none) None
                if
                  > (.len channels) 1
                  Some $ div
                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 6) (:padding 10) (:border-radius 12) (:background-color |#fbfbf8) (:border "|1px solid #d7d7cf") (:margin-top 8)
                    div
                      {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#4b5563)
                      <> |Channels
                    keyed->
                      {} $ :style $ {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                      -> channels .to-list $ map-indexed $ fn (idx channel)
                        keyed-element idx $ button $ {} (:class-name css/button) (:inner-text channel)
                          :style $ {} (:padding "|5px 8px") (:font-size 11)
                            :background-color $ if (selected-channel? selected-channel channel) |#dce3ea |#ffffff
                            :border $ if (selected-channel? selected-channel channel) "|1px solid #8a8f98" "|1px solid #d7d7cf"
                          :on-click $ fn (e d!)
                            d! $ :: :select-channel channel
                  , None
                div
                  {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 10) (:padding 12) (:border-radius 16) (:background-color |#fbfbf8) (:border "|1px solid #d7d7cf") (:min-height |420px) (:margin-top 8)
                  div
                    {} $ :style $ {} (:font-size 13) (:font-weight |600) (:color |#4b5563)
                    <> |Preview
                  if (.none? selected-channel)
                    div
                      {} $ :style $ {} (:padding 20) (:border-radius 14) (:border "|1px dashed #d7d7cf") (:background-color |#f5f5f1) (:font-size 13) (:line-height |1.6) (:color |#6b7280)
                      if
                        > (.len channels) 1
                        <> "|Select a channel to start receiving layouts."
                        <> "|Waiting for a relay channel. Open this page with ?channel=<name>."
                    match
                      decode-map-as
                        .and-then (get renderer :layout) present-option
                        Option app.comp.container/LayoutNode
                      (:some layout) (comp-layout-node layout)
                      (:none)
                        div
                          {} $ :style $ {} (:padding 20) (:border-radius 14) (:border "|1px dashed #d7d7cf") (:background-color |#f5f5f1) (:font-size 13) (:line-height |1.6) (:color |#6b7280)
                          <> "|Waiting for validated payloads."
                .render drawer-plugin
                .render help-alert
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (-> respo.schema/Component) (:features :js-ffi)
        'comp-layout-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-layout-node (node)
            match node
              (:column children)
                keyed->
                  {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 12) (:align-items |stretch)
                  -> children .to-list $ map-indexed $ fn (idx child)
                    keyed-component idx $ comp-layout-node child
              (:row children)
                keyed->
                  {} $ :style $ {} (:display |flex) (:flex-direction |row) (:gap 12) (:flex-wrap |wrap) (:align-items |center)
                  -> children .to-list $ map-indexed $ fn (idx child)
                    keyed-component idx $ comp-layout-node child
              (:card title children)
                div
                  {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 12) (:padding 16) (:border "|1px solid #e4d4c6") (:border-radius 16) (:background-color |#fffdf9)
                  match title
                    (:some title-text)
                      Some $ div
                        {} $ :style $ {} (:font-size 18) (:font-weight |600) (:color |#7e4f2c)
                        <> title-text
                    (:none) None
                  keyed->
                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 10)
                    -> children .to-list $ map-indexed $ fn (idx child)
                      keyed-component idx $ comp-layout-node child
              (:text text)
                div
                  {} $ :style $ {} (:font-size 16) (:line-height |1.6) (:color |#2e241c)
                  <> text
              (:badge text)
                div
                  {} $ :style $ {} (:display |inline-flex) (:align-items |center) (:padding 8) (:border-radius 999) (:background-color |#f3d7ba) (:color |#7d4d27) (:font-size 12) (:font-weight |600) (:width |fit-content)
                  <> text
              (:divider)
                div $ {} $ :style
                  {} (:height 1) (:width |100%) (:background-color |#e6d4c4)
              (:button text)
                button $ {} (:disabled true) (:inner-text text)
                  :style $ {} (:padding 10) (:border "|1px solid #cf8b5d") (:background-color |#e8b488) (:color |#3e2515) (:border-radius 999) (:font-size 14) (:font-weight |600) (:cursor |not-allowed)
              (:input name placeholder value)
                input $ {} (:disabled true)
                  :value $ .unwrap-or value |
                  :placeholder $ .unwrap-or placeholder $ .unwrap-or name |Input
                  :style $ {} (:padding 10) (:border "|1px solid #d8c8ba") (:border-radius 12) (:font-size 14) (:background-color |#fff) (:min-width |160px)
              (:markdown text)
                div
                  {} $ :style $ {} (:padding 18) (:border-radius 18) (:background-color |#fffdf9) (:border "|1px solid #e8d7ca")
                  comp-markdown-block text
              (:mermaid text) (comp-mermaid-block text)
              (:chart kind title series)
                div
                  {} $ :style $ {} (:padding 18) (:border-radius 18) (:background-color |#fffdf9) (:border "|1px solid #e8d7ca")
                  comp-chart-block series kind title
              (:math expr display) (comp-math-block expr display)
              _ $ div
                {} $ :style $ {} (:padding 12) (:border "|1px solid #f08c6c") (:border-radius 12) (:background-color |#fff4ef) (:color |#9b3d15)
                <> "|Unsupported layout node"
          :examples $ []
          :schema $ quote $ Fn LayoutNode (-> respo.schema/Component) (:features :js-ffi)
        'comp-markdown-block $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-markdown-block (text)
            let
                lines $ split-lines text
              keyed->
                {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 8)
                -> lines .to-list $ map-indexed $ fn (idx line)
                  keyed-element idx $ cond
                      blank? line
                      div $ {} $ :style
                        {} $ :height 6
                    (starts-with? line "|### ")
                      div
                        {} $ :style $ {} (:font-size 18) (:font-weight |600) (:color |#6b4528)
                        <> $ slice line 4
                    (starts-with? line "|## ")
                      div
                        {} $ :style $ {} (:font-size 22) (:font-weight |700) (:color |#583722)
                        <> $ slice line 3
                    (starts-with? line "|# ")
                      div
                        {} $ :style $ {} (:font-size 28) (:font-weight |700) (:color |#3a2417)
                        <> $ slice line 2
                    (starts-with? line "|- ")
                      div
                        {} $ :style $ {} (:display |flex) (:align-items |flex-start) (:gap 8) (:font-size 15) (:line-height |1.7) (:color |#2e241c)
                        span
                          {} $ :style $ {} (:color |#b36a36) (:font-weight |700)
                          <> "|•"
                        <> $ slice line 2
                    (starts-with? line "|> ")
                      div
                        {} $ :style $ {} (:padding-left 14) (:border-left "|3px solid #d7bca4") (:font-size 15) (:line-height |1.7) (:color |#6e553d)
                        <> $ slice line 2
                    true $ div
                      {} $ :style $ {} (:font-size 15) (:line-height |1.7) (:color |#2e241c) (:white-space |pre-wrap)
                      <> line
          :examples $ []
          :schema $ quote $ Fn String (-> respo.schema/Component) (:features :js-ffi)
        'comp-math-block $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-math-block (expr display)
            let
                block? $ = (math-display-value display) |block
              [] (effect-mathml expr display)
                div $ {} (:class-name |mathml-host)
                  :style $ .merge
                    {} (:padding 18) (:border-radius 18) (:background-color |#fffdf9) (:border "|1px solid #e8d7ca") (:overflow |auto) (:color |#2e241c) (:max-width |100%) (:align-self |flex-start)
                    if block?
                      {} $ :width |100%
                      {} $ :width |fit-content
          :examples $ []
          :schema $ quote $ Fn MathExpr String (-> respo.schema/Component) (:features :js-ffi)
        'comp-mermaid-block $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-mermaid-block (text)
            let
                payload $ build-mermaid-render-payload text
                svg-str $ if (:empty? payload) None $ match
                  get @*rendered-svgs $ :source payload
                  (:none) None
                  (:some result)
                    match result
                      (:ready svg) (Some svg)
                      (:rendering) None
                      (:failed) None
              [] (effect-mermaid text)
                div
                  {} (:class-name |mermaid-host)
                    :style $ {} (:display |flex) (:flex-direction |column) (:gap 10) (:padding 16) (:border-radius 16) (:border "|1px solid #d9cabf") (:background-color |#fffdf9)
                  div
                    {} $ :style $ {} (:font-size 13) (:font-weight |700) (:letter-spacing |1px) (:text-transform |uppercase) (:color |#8b6244)
                    <> |Mermaid
                  div $ {} (:class-name |mermaid-output)
                    :style $ {} (:min-height |120px) (:padding 12) (:border-radius 12) (:background-color |#fff) (:overflow |auto) (:border "|1px solid #eadccf") (:color |#6f5743) (:font-size 13) (:line-height |1.6) (:white-space |pre-wrap)
                    :innerHTML $ .unwrap-or svg-str "|Rendering Mermaid diagram..."
          :examples $ []
          :schema $ quote $ Fn String (-> respo.schema/Component) (:features :js-ffi)
        'dispose-echarts-on! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispose-echarts-on! (el)
            let
                existing $ unsafe-coerce (echarts-lib/getInstanceByDom el) (JsNullish JsObject)
              if (js-present? existing)
                let
                    chart $ js-cast existing 'EChartHost
                  chart .dispose!
                , &unit
          :examples $ []
          :schema $ quote $ Fn browser/DomElementHost (-> Unit) (:features :js-ffi)
        'effect-echarts $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-echarts (option) (action el at?)
            let
                target $ browser/element-host el
              match action
                :mount $ render-echarts-on! target $ decode-map-as option (Map Tag app.comp.container/ChartOptionValue)
                :update $ render-echarts-on! target $ decode-map-as option (Map Tag app.comp.container/ChartOptionValue)
                :unmount $ dispose-echarts-on! target
                _ &unit
          :examples $ []
          :schema $ quote $ Fn (Map Tag ChartOptionValue) (-> respo.schema/Effect) (:features :js-ffi)
        'effect-mathml $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-mathml (expr display) (action el at?)
            let
                target $ js-cast el 'MathElementHost
              match action
                :mount $ render-mathml-on target (decode-map-as expr app.comp.container/MathExpr) (decode-map-as display 'String)
                :update $ render-mathml-on target (decode-map-as expr app.comp.container/MathExpr) (decode-map-as display 'String)
                :unmount $ do (js-set target :inner-html |) &unit
                _ &unit
          :examples $ []
          :schema $ quote $ Fn MathExpr String (-> respo.schema/Effect) (:features :js-ffi)
        'effect-mermaid $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-mermaid (text) (action el at?)
            let
                payload $ build-mermaid-render-payload $ decode-map-as text 'String
                target $ browser/element-host el
              match action
                :mount $ if (:empty? payload) &unit $ render-mermaid-on target payload
                :update $ if (:empty? payload) &unit $ render-mermaid-on target payload
                :unmount &unit
                _ &unit
          :examples $ []
          :schema $ quote $ Fn String (-> respo.schema/Effect) (:features :js-ffi)
        'effect-page-title $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-page-title (selected-channel) (action el at?)
            let
                next-title $ page-title-text $ decode-map-as selected-channel (Option String)
              match action
                :mount $ browser/document-title! next-title
                :update $ browser/document-title! next-title
                :unmount $ browser/document-title! $ page-title-text None
                _ &unit
          :examples $ []
          :schema $ quote $ Fn (Option String) (-> respo.schema/Effect) (:features :js-ffi)
        'ensure-mermaid! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn ensure-mermaid! ()
            if (not @*mermaid-ready)
              let
                  api $ js-cast mermaid-lib 'MermaidHost
                api .initialize! $ js-object (:startOnLoad false) (:securityLevel |loose) (:theme |neutral)
                reset! *mermaid-ready true
                , &unit
              , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'math-display-value $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn math-display-value (display)
            if (&= display |block) |block |inline
          :examples $ []
          :schema $ quote $ Fn T (-> String) (:generics T)
        'mathml-namespace $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def mathml-namespace |http://www.w3.org/1998/Math/MathML
          :examples $ []
          :schema $ quote String
        'page-title-text $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn page-title-text (selected-channel)
            str |EDN-Renderer/ $ .unwrap-or selected-channel |waiting
          :examples $ []
          :schema $ quote $ Fn (Option String) (-> String)
        'parse-layout-children $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-layout-children (children path)
            if (list? children)
              map children $ fn (child)
                hint-fn $ Fn Dynamic $ -> LayoutNode
                parse-layout-node child $ str path |.children
              raise $ str path "| field :children should be a list"
          :examples $ []
          :schema $ quote $ Fn T String
            -> $ List LayoutNode
            :generics T
        'parse-layout-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-layout-node (node path)
            if (map? node)
              let
                  node-type $ match (field node :type)
                    (:some value)
                      if (string? value) value |
                    (:none) |
                  children $ field-or node :children $ []
                  series $ field-or node :series $ []
                  text $ field-or node :text |
                if (not= node-type |)
                  match node-type
                    |column $ LayoutNode :column $ parse-layout-children children path
                    |row $ LayoutNode :row $ parse-layout-children children path
                    |card $ LayoutNode :card
                      match (field node :text)
                        (:some card-text)
                          if (string? card-text) (Some card-text)
                            raise $ str path "| card node requires string :text"
                        (:none) None
                      parse-layout-children children path
                    |text $ if (string? text)
                      if
                        > (.len text) 0
                        LayoutNode :text text
                        raise $ str path "| text node requires non-empty :text"
                      raise $ str path "| text node requires non-empty :text"
                    |badge $ if (string? text)
                      if
                        > (.len text) 0
                        LayoutNode :badge text
                        raise $ str path "| badge node requires non-empty :text"
                      raise $ str path "| badge node requires non-empty :text"
                    |divider $ LayoutNode :divider
                    |button $ if (string? text)
                      if
                        > (.len text) 0
                        LayoutNode :button text
                        raise $ str path "| button node requires non-empty :text"
                      raise $ str path "| button node requires non-empty :text"
                    |input $ if
                      or (field-is? node :name non-nil?) (field-is? node :placeholder non-nil?)
                      LayoutNode :input (field node :name) (field node :placeholder) (field node :text)
                      raise $ str path "| input node requires :name or :placeholder"
                    |markdown $ if (string? text)
                      if
                        > (.len text) 0
                        LayoutNode :markdown text
                        raise $ str path "| markdown node requires non-empty :text"
                      raise $ str path "| markdown node requires non-empty :text"
                    |mermaid $ if (string? text)
                      if
                        > (.len text) 0
                        LayoutNode :mermaid text
                        raise $ str path "| mermaid node requires non-empty :text"
                      raise $ str path "| mermaid node requires non-empty :text"
                    |chart $ if (list? series)
                      LayoutNode :chart
                        match (field-or node :kind |bar)
                          |line $ ChartKind :line
                          |pie $ ChartKind :pie
                          |scatter $ ChartKind :scatter
                          _ $ ChartKind :bar
                        let
                            title $ field-or node :title |
                          if
                            or (nil? title) (= title |)
                            , None $ Some $ str title
                        map
                          decode-map-as series $ List Dynamic
                          fn (item)
                            hint-fn $ Fn Dynamic $ -> ChartDatum
                            if (map? item)
                              if
                                and (field-is? item :label string?) (field-is? item :value number?)
                                ChartDatum :label
                                  decode-map-as
                                    .unwrap $ get item :label
                                    , String
                                  , :value $ decode-map-as
                                    .unwrap $ get item :value
                                    , Number
                                raise $ str path "| chart series item requires string :label and number :value"
                              raise $ str path "| chart series item should be a map"
                      raise $ str path "| chart node requires list field :series"
                    |math $ LayoutNode :math
                      match (field node :expr)
                        (:some expr)
                          validate-mathml-expr expr $ str path |.expr
                        (:none)
                          raise $ str path "|.expr math node requires list field :expr"
                      math-display-value $ field-or node :display |inline
                    _ $ raise $ str path "| does not support node type " node-type
                  raise $ str path "| is missing string field :type"
              raise $ str path "| expected a map node"
          :examples $ []
          :schema $ quote $ Fn T String (-> LayoutNode) (:generics T)
        'present-option $ %{} 'CodeEntry
          :doc "|Read a store slot that may hold nil as an Option, so typed decoding happens on `Option :some` only."
          :code $ quote $ defn present-option (value)
            if (nil? value) None $ Some value
          :examples $ []
          :schema $ quote $ Fn T
            -> $ Option T
            :generics T
        'render-echarts-on! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-echarts-on! (el option)
            let
                existing $ unsafe-coerce (echarts-lib/getInstanceByDom el) (JsNullish JsObject)
                chart $ if (js-present? existing) (js-cast existing 'EChartHost)
                  js-cast (echarts-lib/init el) 'EChartHost
                plain-option $ contract/expect-object |render-echarts-on! $ to-js-data option
              chart .set-option! plain-option true
          :examples $ []
          :schema $ quote $ Fn browser/DomElementHost (Map Tag ChartOptionValue) (-> Unit) (:features :js-ffi)
        'render-mathml-on $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-mathml-on (el expr display)
            let
                root $ build-mathml-root expr display
              js-set el :inner-html |
              el .append-child! $ contract/expect-object |render-mathml-on root
              , &unit
          :examples $ []
          :schema $ quote $ Fn MathElementHost MathExpr String (-> Unit) (:features :js-ffi)
        'render-mermaid-on $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-mermaid-on (el payload)
            hint-fn $ Fn browser/DomElementHost MermaidPayload (-> Unit) (:features :js-ffi) (:async)
            let
                source $ :source payload
                graph-id $ :graph-id payload
              match (browser/element-query-selector el |.mermaid-output)
                (:none) (host/console-warn! "|[mermaid] missing .mermaid-output")
                (:some output)
                  if
                    .some? $ get @*rendered-svgs source
                    , &unit $ do
                      reset! *rendered-svgs $ assoc @*rendered-svgs source $ MermaidCache :rendering
                      ensure-mermaid!
                      try
                        let
                            api $ js-cast mermaid-lib 'MermaidHost
                            result $ unsafe-coerce
                              js-await $ api .render graph-id source
                              , MermaidResultHost
                            svg $ result :svg
                          browser/element-set-inner-html! output svg
                          match
                            js-nullish->option $ result :bind-functions
                            (:none) &unit
                            (:some bind-fns) (bind-fns output)
                          reset! *rendered-svgs $ assoc @*rendered-svgs source $ MermaidCache :ready svg
                          , &unit
                        fn (error)
                          hint-fn $ Fn Dynamic $ -> Unit
                          reset! *rendered-svgs $ assoc @*rendered-svgs source $ MermaidCache :failed
                          host/console-error! $ str "|[mermaid] render failed: " error
          :examples $ []
          :schema $ quote $ Fn browser/DomElementHost MermaidPayload (-> Unit) (:features :js-ffi)
        'selected-channel? $ %{} 'CodeEntry
          :doc "|Whether the optional selected channel is this channel."
          :code $ quote $ defn selected-channel? (selected channel)
            match selected
              (:some current) (= current channel)
              (:none) false
          :examples $ []
          :schema $ quote $ Fn (Option String) String (-> Bool)
        'storage-kind? $ %{} 'CodeEntry
          :doc "|Whether the optional selected storage entry has this :kind."
          :code $ quote $ defn storage-kind? (selected kind)
            match selected
              (:some entry)
                = (Some kind) (field entry :kind)
              (:none) false
          :examples $ []
          :schema $ quote $ Fn
            Option $ Map Tag Dynamic
            , Tag (-> Bool)
        'validate-layout $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn validate-layout (layout) (parse-layout-node layout |root)
          :examples $ []
          :schema $ quote $ Fn T (-> LayoutNode) (:generics T)
        'validate-layout-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn validate-layout-node (node path) (parse-layout-node node path)
          :examples $ []
          :schema $ quote $ Fn T String (-> LayoutNode) (:generics T)
        'validate-mathml-child $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn validate-mathml-child (child path)
            if (string? child) child $ if (number? child) child $ if (list? child) (validate-mathml-expr child path)
              raise $ str path "| invalid MathML child, expected string, number, or list"
          :examples $ []
          :schema $ quote $ Fn T String (-> MathChild) (:generics T)
        'validate-mathml-expr $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn validate-mathml-expr (expr path)
            if (list? expr)
              match (first expr)
                (:some tag-name)
                  if (string? tag-name)
                    let
                        children $ map (rest expr)
                          fn (child)
                            hint-fn $ Fn Dynamic $ -> MathChild
                            validate-mathml-child child $ str path |/ tag-name
                      MathExpr :tag tag-name :children children
                    raise $ str path "| math expression requires string tag name"
                (:none)
                  raise $ str path "| math expression should not be empty"
              raise $ str path "| math node requires list field :expr"
          :examples $ []
          :schema $ quote $ Fn T String (-> MathExpr) (:generics T)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require (respo-ui.css :as css)
            app.field :refer $ field field-is? field-or put-field
            respo.css :refer $ defstyle
            respo.core :refer $ defcomp defeffect <> >> div button textarea span input keyed-> keyed-element keyed-component
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            app.config :refer $ dev?
            |echarts :as echarts-lib
            |mermaid :default mermaid-lib
            respo-alerts.core :refer $ use-alert use-drawer
            js-ffi.browser :as browser
            js-ffi.shared :as host
            js-ffi.contract :as contract
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'build-help-payload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-help-payload (topics)
            let
                normalized-topics $ if (list? topics) topics $ []
              {} (:status :ok) (:kind :help) (:renderer |edn-renderer) (:summary renderer-help-overview) (:commands relay-commands) (:topics normalized-topics)
                :components $ select-component-docs normalized-topics
                :protocol_docs $ select-protocol-docs normalized-topics
                :examples $ select-example-docs normalized-topics
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Map Tag Dynamic
        'build-skill-payload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-skill-payload (topics)
            let
                normalized-topics $ if (list? topics) topics $ []
                full? $ includes? normalized-topics |full
                text $ if full? skill-text $ if (empty? normalized-topics) skill-overview (build-skill-text normalized-topics)
              {} (:status :ok) (:kind :skill) (:renderer |edn-renderer)
                :title $ if full? "|edn-renderer Skill (full)" "|edn-renderer Skill"
                :text text
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Map Tag Dynamic
        'build-skill-text $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-skill-text (topics)
            let
                sections $ select-skill-sections topics
              .foldl sections skill-overview $ fn (acc item)
                hint-fn $ Fn String (Map Tag String) (-> String)
                str acc "|\n\n## "
                  .unwrap $ get item :title
                  , "|\n\n" $ .unwrap $ get item :text
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> String)
        'build-status-payload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-status-payload (relay renderer)
            ->
              {} (:status :ok) (:kind :status) (:renderer |edn-renderer)
                :title $ current-page-title
                :page_url $ current-page-url
                :commands relay-commands
                :channels $ field-or relay :channels $ []
                :layout_ready? $ field-is? renderer :layout-dsl non-nil?
              put-field :channel $ field relay :selected-channel
              put-field :layout_id $ field renderer :layout-id
              put-field :last_request $ field renderer :last-request
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (Map Tag Dynamic)
            -> $ Map Tag Dynamic
            :features :js-ffi
        'component-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def component-docs
            []
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
              {} (:name |math)
                :summary "|MathML Core 节点，使用 Cirru EDN list 简写 `:expr` 描述公式，再由浏览器原生 MathML 渲染。"
                :fields $ [] |expr |display
                :example "|{}\n  :type |math\n  :display |block\n  :expr $ [] |mfrac\n    [] |mrow\n      [] |mi |a\n      [] |mo |+\n      [] |mi |b\n    [] |msqrt\n      [] |mi |c"
              {} (:name |button) (:summary "|只读展示按钮。")
                :fields $ [] |text
                :example "|{} (:type |button) (:text |Confirm)"
              {} (:name |input) (:summary "|只读展示输入框。")
                :fields $ [] |name |placeholder |text
                :example "|{} (:type |input) (:name |email) (:placeholder |Email)"
          :examples $ []
          :schema $ quote $ List (Map Tag Dynamic)
        'current-page-title $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-page-title () (browser/document-title)
          :examples $ []
          :schema $ quote $ Fn (-> String) (:features :js-ffi)
        'current-page-url $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-page-url () (browser/location-href)
          :examples $ []
          :schema $ quote $ Fn (-> String) (:features :js-ffi)
        'current-relay-url $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-relay-url ()
            match (current-url-param |server)
              (:some server) server
              (:none)
                match (current-url-param |port)
                  (:some port) (str |ws://127.0.0.1: port)
                  (:none)
                    .unwrap $ get site :relay-url
          :examples $ []
          :schema $ quote $ Fn (-> String) (:features :js-ffi)
        'current-url-channel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-url-channel () (current-url-param |channel)
          :examples $ []
          :schema $ quote $ Fn
            -> $ Option String
            :features :js-ffi
        'current-url-param $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-url-param (key)
            let
                params $ shared/search-params-create $ :search (browser/location-snapshot)
              match (shared/search-params-get params key)
                (:some value)
                  if (empty? value) None $ Some value
                (:none) None
          :examples $ []
          :schema $ quote $ Fn String
            -> $ Option String
            :features :js-ffi
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ .unwrap-or (get-env |mode) |release
          :examples $ []
          :schema $ quote Bool
        'example-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def example-docs
            []
              {} (:name |card-demo) (:summary "|最小 card 示例。")
                :payload "|{}\n  :type |card\n  :text \"|CLI Demo\"\n  :children $ []\n    {} (:type |badge) (:text |preview)\n    {} (:type |text) (:text \"|Hello from CLI\")"
              {} (:name |layout-summary-demo) (:summary "|查询当前 layout summary tree。") (:payload "|{}\n  :op :layout")
              {} (:name |layout-snapshot-demo) (:summary "|查询当前 layout 的稳定裁剪快照，适合脚本化验证。") (:payload "|{}\n  :op :snapshot")
              {} (:name |layout-node-demo) (:summary "|按路径读取一个节点的完整 DSL。") (:payload "|{}\n  :op :node\n  :path |1.2")
              {} (:name |layout-patch-demo) (:summary "|按路径局部更新节点属性。")
                :payload "|{}\n  :op :patch\n  :path |1\n  :changes $ {} (:text \"|Updated title\")"
              {} (:name |layout-replace-demo) (:summary "|按路径替换整棵子树。")
                :payload "|{}\n  :op :replace\n  :path |2.1\n  :node $ {} (:type |text) (:text \"|Replaced from CLI\")"
              {} (:name |chart-demo) (:summary "|折线图示例。")
                :payload "|{}\n  :type |chart\n  :kind |line\n  :title \"|Traffic trend\"\n  :series $ []\n    {} (:label |Mon) (:value 120)\n    {} (:label |Tue) (:value 132)\n    {} (:label |Wed) (:value 148)"
              {} (:name |math-fraction-demo) (:summary "|MathML 分式示例。")
                :payload "|{}\n  :type |math\n  :display |block\n  :expr $ [] |mfrac\n    [] |mrow\n      [] |mi |a\n      [] |mo |+\n      [] |mi |b\n    [] |msqrt\n      [] |mi |c"
              {} (:name |math-quadratic-demo) (:summary "|MathML 二次方程求根公式。")
                :payload "|{}\n  :type |math\n  :display |block\n  :expr $ [] |mfrac\n    [] |mrow\n      [] |mo |−\n      [] |mi |b\n      [] |mo |±\n      [] |msqrt\n        [] |mrow\n          [] |msup\n            [] |mi |b\n            [] |mn |2\n          [] |mo |−\n          [] |mn |4\n          [] |mi |a\n          [] |mi |c\n    [] |mrow\n      [] |mn |2\n      [] |mi |a"
              {} (:name |mermaid-demo) (:summary "|Mermaid 流程图示例。")
                :payload "|{}\n  :type |mermaid\n  :text \"|flowchart LR\\n  A --> B\\n  B --> C\""
          :examples $ []
          :schema $ quote $ List (Map Tag String)
        'protocol-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def protocol-docs
            []
              {} (:name |channel)
                :summary "|每个 renderer 连接只订阅一个当前 channel；URL 上的 `?channel=` 可以直接指定或创建它。发布版页面还支持 `?server=` 或 `?port=` 指向 relay。"
              {} (:name |hello)
                :summary "|浏览器连接 relay 后先发送 `hello`，服务端会返回 `hello-ok` 和当前活跃 channel 列表。"
              {} (:name |channel-state) (:summary "|当活跃 channel 列表变化时，relay 会广播 `channel-state`。")
              {} (:name |ack) (:summary "|同一个请求允许多个 receiver 收到事件，但 sender 只接受第一条 `ack`。")
              {} (:name |editing)
                :summary "|局部编辑推荐顺序是先 `:layout` 看 summary tree，再用 `:node` 读取完整 DSL，最后按改动大小选择 `:patch` 或 `:replace`。成功响应都会回新的 `:layout_id`，并附当前节点 `:summary`，变更类操作还会附 `:dsl`。"
              {} (:name |layout)
                :summary "|CLI 上优先用 `{:op :layout}` 查询当前 layout 概览；可附 `:path` 只看某个子树。summary 节点会带 `:path`、`:type`、`:child-count` 和少量摘要字段。"
              {} (:name |snapshot)
                :summary "|脚本化验证优先用 `{:op :snapshot}` 查询稳定的裁剪版 layout 树；默认返回整棵树，也支持 `:path` 只抓某个子树。返回字段刻意裁剪，避免测试依赖完整 DSL。"
              {} (:name |node)
                :summary "|用 `:op :node` + `:path \"1.2.3\"` 读取某个节点的完整 DSL。路径使用 1-based children 索引，`root` 表示整棵树；成功时同时返回 `:dsl`、`:source` 和 `:summary`。"
              {} (:name |patch)
                :summary "|用 `:op :patch` + `:path` + `:changes` 局部合并节点属性，renderer 会重新验证整棵 layout；成功后立即局部更新页面，并返回目标节点新的 `:dsl` 与 `:summary`。"
              {} (:name |replace)
                :summary "|用 `:op :replace` + `:path` + `:node` 直接替换某个节点 DSL，适合结构性修改；成功后同样会重新验证整棵树，并返回替换结果。"
              {} (:name |storage)
                :summary "|页面上的 `Save` 和 `Library` 通过 relay 保留 channel `__relay_store__` 工作。`Save` 会把当前 report 落到 `~/.config/ed-relay/<channel>/`，`Library` 会列出同 channel 的 `.cirru` 文件并加载回当前预览。"
          :examples $ []
          :schema $ quote $ List (Map Tag String)
        'relay-commands $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def relay-commands ([] |send |help |skill |status |open)
          :examples $ []
          :schema $ quote $ List String
        'renderer-help-overview $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def renderer-help-overview "|默认 `edn-relay help --channel <name>` 只返回总览；需要细节时再追加 topic，例如 `components`、`math`、`protocol`、`storage`、`editing`、`examples`、`layout`、`snapshot`、`layout-patch-demo`、`math-fraction-demo`，避免一次返回全部组件配置和案例。"
          :examples $ []
          :schema $ quote String
        'select-component-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-component-docs (topics)
            let
                normalized-topics $ if (list? topics)
                  assert-type topics $ List Dynamic
                  []
              if (includes? normalized-topics |components) component-docs $ filter component-docs $ fn (item)
                hint-fn $ Fn (Map Tag Dynamic) (-> Bool)
                includes? normalized-topics $ .unwrap $ get item :name
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ List $ Map Tag Dynamic
        'select-example-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-example-docs (topics)
            let
                normalized-topics $ if (list? topics)
                  assert-type topics $ List Dynamic
                  []
              if (includes? normalized-topics |examples) example-docs $ filter example-docs $ fn (item)
                hint-fn $ Fn (Map Tag String) (-> Bool)
                includes? normalized-topics $ .unwrap $ get item :name
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ List $ Map Tag String
        'select-protocol-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-protocol-docs (topics)
            let
                normalized-topics $ if (list? topics)
                  assert-type topics $ List Dynamic
                  []
              if (includes? normalized-topics |protocol) protocol-docs $ filter protocol-docs $ fn (item)
                hint-fn $ Fn (Map Tag String) (-> Bool)
                includes? normalized-topics $ .unwrap $ get item :name
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ List $ Map Tag String
        'select-skill-sections $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-skill-sections (topics)
            let
                normalized-topics $ if (list? topics)
                  assert-type topics $ List Dynamic
                  []
              if (includes? normalized-topics |all) skill-sections $ filter skill-sections $ fn (item)
                hint-fn $ Fn (Map Tag String) (-> Bool)
                includes? normalized-topics $ .unwrap $ get item :name
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ List $ Map Tag String
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            {} (:storage-key |workflow) (:relay-url |ws://127.0.0.1:9100)
          :examples $ []
          :schema $ quote $ Map Tag String
        'skill-overview $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def skill-overview "|使用 `edn-relay skill --channel <name>` 获取高层工作流；默认只返回总览。需要细节时追加 topic，例如 `workflow`、`help`、`storage`、`layout`、`math`、`validation`；如果确实要整份文档，再用 `full`。"
          :examples $ []
          :schema $ quote String
        'skill-sections $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def skill-sections
            []
              {} (:name |workflow) (:title |Workflow)
                :text "|1. 先 `edn-relay help --channel <name>` 看总览。\n2. 再用 `help --channel <name> <topic>` 把范围收窄到组件、协议或示例。\n3. 最后才运行 `edn-relay send --channel <name> ...` 发 payload。"
              {} (:name |help) (:title "|Help Queries")
                :text "|默认 `help` 只返回总览。要列出全部组件，用 `edn-relay help --channel <name> components`；要看 MathML，用 `edn-relay help --channel <name> math`；要看局部编辑流程，用 `edn-relay help --channel <name> editing`；要看脚本化快照接口，用 `edn-relay help --channel <name> snapshot`；要看具体案例，用 `edn-relay help --channel <name> layout-patch-demo`。"
              {} (:name |storage) (:title |Storage)
                :text "|页面上已有有效 report 时，可以直接点 `Save` 把当前内容保存到 `~/.config/ed-relay/<channel>/`。点 `Library` 会请求 relay 列出当前 channel 下的 `.cirru` 文件，并在点击条目后把保存时的 layout 加载回当前预览。CLI 想查这个能力时，优先用 `edn-relay help --channel <name> storage`。"
              {} (:name |editing) (:title "|Editing Workflow")
                :text "|先用 `edn-relay send --channel <name> '{}` + `:op :snapshot` 或 `:op :layout` 获取裁剪过的概览树，再用 `:op :node` + `:path` 读取完整 DSL。只改属性时优先 `:patch` + `:changes`，结构变化再用 `:replace`。每次成功都会回新的 `:layout_id`、目标节点 `:summary`，并在 `node/patch/replace` 返回完整 `:dsl`。"
              {} (:name |layout) (:title "|Layout Editing")
                :text "|局部编辑默认走 `snapshot/layout -> node -> patch/replace`。脚本化验证优先 `snapshot`，人工排查优先 `layout`。路径使用 1-based children 索引，`root` 表示整棵树；如果 agent 还不确定 payload 形状，先查 `layout-summary-demo`、`layout-snapshot-demo`、`layout-node-demo`、`layout-patch-demo`。"
              {} (:name |math) (:title |MathML)
                :text "|MathML Core 已通过 `math` 节点暴露。推荐顺序是先查 `edn-relay help --channel genui math`，再查 `math-fraction-demo`，最后发送 `:type |math` + `:expr` 的 Cirru EDN payload。"
              {} (:name |validation) (:title |Validation)
                :text "|浏览器验证优先看 `chrome-devtools take_snapshot` 和 `chrome-devtools list_console_messages`；CLI 侧优先看 `status`、`help`、`skill` 是否和当前页面一致。局部编辑失败时，优先检查返回的 `ack false` 和对应 `:path`。"
          :examples $ []
          :schema $ quote $ List (Map Tag String)
        'skill-text $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def skill-text (slurp-file |SKILL.md)
          :examples $ []
          :schema $ quote String
        'slurp-file $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defmacro slurp-file (file-path)
            read-file $ assert-type file-path String
          :examples $ []
          :schema $ quote $ Macro Syntax
            -> $ Expr String
            :capabilities :fs-read
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
          :require (js-ffi.browser :as browser) (js-ffi.shared :as shared)
            app.field :refer $ field field-is? field-or put-field
    'app.field $ %{} 'FileEntry
      :defs $ {}
        'field $ %{} 'CodeEntry
          :doc "|Read an optional map field as an Option. A missing key and a stored nil both read as None, matching how the store and relay frames use nil for absence."
          :code $ quote $ defn field (m k)
            match (get m k)
              (:some v)
                if (nil? v) None $ Some v
              (:none) None
          :examples $ []
          :schema $ quote $ Fn Dynamic Dynamic
            -> $ Option Dynamic
          :tests $ [] $ %{} 'TestEntry (:name |folds-nil-into-none)
            :code $ quote $ let
                m $ {} (:a 1) (:b nil) (:c false)
              assert= (Some 1) (field m :a)
              assert= None $ field m :b
              assert= None $ field m :missing
              assert= (Some false) (field m :c)
            :tags $ #{} :unit
        'field-is? $ %{} 'CodeEntry
          :doc "|Whether a map field is present and its value passes pred. A missing key is false without calling pred."
          :code $ quote $ defn field-is? (m k pred)
            match (get m k)
              (:some v) (pred v)
              (:none) false
          :examples $ []
          :schema $ quote $ Fn (Map K V) K
            Fn V $ -> Bool
            -> Bool
            :generics K V
          :tests $ [] $ %{} 'TestEntry (:name |checks-present-values)
            :code $ quote $ let
                m $ {} (:a |x) (:b nil)
              assert= true $ field-is? m :a string?
              assert= false $ field-is? m :b non-nil?
              assert= false $ field-is? m :missing non-nil?
            :tags $ #{} :unit
        'field-or $ %{} 'CodeEntry
          :doc "|Read a map field with `or` semantics: a missing key, nil or false gives fallback."
          :code $ quote $ defn field-or (m k fallback)
            match (get m k)
              (:some v) (or v fallback)
              (:none) fallback
          :examples $ []
          :schema $ quote $ Fn Dynamic Dynamic Dynamic (-> Dynamic)
          :tests $ [] $ %{} 'TestEntry (:name |falls-back-like-or)
            :code $ quote $ let
                m $ {} (:a |x) (:b nil) (:c false)
              assert= |x $ field-or m :a |d
              assert= |d $ field-or m :b |d
              assert= |d $ field-or m :c |d
              assert= |d $ field-or m :missing |d
            :tags $ #{} :unit
        'put-field $ %{} 'CodeEntry
          :doc "|Set a map field from an Option: `:some` stores the value, `:none` removes the key, so absence stays absence instead of becoming a stored nil."
          :code $ quote $ defn put-field (m k value)
            match value
              (:some v) (assoc m k v)
              (:none) (dissoc m k)
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) Tag (Option V)
            -> $ Map Tag Dynamic
            :generics V
          :tests $ [] $ %{} 'TestEntry (:name |assoc-or-dissoc)
            :code $ quote $ let
                m $ {} (:a 1) (:b 2)
              assert=
                {} (:a 3) (:b 2)
                put-field m :a $ Some 3
              assert=
                {} $ :b 2
                put-field m :a None
            :tags $ #{} :unit
      :ns $ %{} 'NsEntry
        :doc "|Helpers for reading optional fields of open maps (store slots, relay frames, layout DSL) without turning an Option back into nil."
        :code $ quote $ ns app.field
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reel
            -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
          :examples $ []
          :schema $ quote $ Ref (Map Tag Dynamic)
        '*ws $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *ws None
          :examples $ []
          :schema $ quote $ Ref (Option browser/WebSocketHost)
        'LayoutPath $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defunion LayoutPath app.main/PathSegment (List app.main/PathSegment)
          :examples $ []
          :schema $ quote UnionDef
        'PathSegment $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defunion PathSegment Number String Tag
          :examples $ []
          :schema $ quote UnionDef
        'RendererRequest $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum RendererRequest
            :help $ List String
            :skill $ List String
            :status
            :snapshot $ List Number
            :layout $ List Number
            :node $ List Number
            :patch (List Number) (Option Dynamic)
            :replace (List Number) (Option Dynamic)
            :invalid
          :examples $ []
          :schema $ quote EnumDef
        'build-saved-report-entry $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-saved-report-entry (relay renderer)
            let
                channel $ field relay :selected-channel
                layout-dsl $ field renderer :layout-dsl
                layout-id $ field renderer :layout-id
                saved-at $ :iso $ host/date-now-snapshot
                source $ match (field renderer :layout-source)
                  (:some layout-source) layout-source
                  (:none)
                    format-cirru-edn $ .unwrap layout-dsl
              ->
                {} (:kind :saved-report)
                  :title $ str (.unwrap-or channel |report) "| / " $ .unwrap-or layout-id |snapshot
                  :saved_at saved-at
                  :source source
                put-field :channel channel
                put-field :layout_id layout-id
                put-field :request_id $ field renderer :last-request
                put-field :layout layout-dsl
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (Map Tag Dynamic)
            -> $ Map Tag Dynamic
            :features :js-ffi
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when
              and config/dev? $ not= op :states
              js/console.log |Dispatch: op
            let
                next-reel $ reel-updater
                  fn (store op op-id op-time)
                    hint-fn $ Fn Dynamic Dynamic Dynamic Dynamic $ -> (Map Tag Dynamic)
                    updater
                      decode-map-as store $ Map Tag Dynamic
                      , op (decode-map-as op-id 'String) (decode-map-as op-time 'Number)
                  , @*reel op
              reset! *reel next-reel
              match @*ws
                (:some socket)
                  match op
                    (:select-channel _) (sync-selected-channel! socket)
                    (:request-storage-list) (request-storage-list! socket)
                    (:save-current-report) (request-storage-save! socket)
                    (:load-stored-report name)
                      request-storage-load! socket $ decode-map-as name 'String
                    _ &unit
                (:none) &unit
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> Unit) (:features :js-ffi)
        'ensure-relay! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn ensure-relay! ()
            when (.none? @*ws)
              dispatch! $ :: :relay-status |connecting nil
              let
                  relay-url $ config/current-relay-url
                  ws $ browser/web-socket-create relay-url
                  client-id $ str |renderer- $ :iso (host/date-now-snapshot)
                reset! *ws $ Some ws
                browser/web-socket-on-open! ws $ fn (event)
                  dispatch! $ :: :relay-connected client-id $ []
                  sync-selected-channel! ws
                browser/web-socket-on-message! ws $ fn (text) (handle-relay-message! ws text) &unit
                browser/web-socket-on-error! ws $ fn (event)
                  dispatch! $ :: :relay-status |error "|Relay websocket error"
                browser/web-socket-on-close! ws $ fn (event) (reset! *ws None)
                  dispatch! $ :: :relay-status |closed "|Relay connection closed, retrying..."
                  browser/set-timeout! ensure-relay! 2000
                  , &unit
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'handle-channel-state! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-channel-state! (ws client-id channels)
            let
                normalized $ if (list? channels)
                  decode-map-as channels $ List String
                  []
              match client-id
                (:some id)
                  dispatch! $ :: :relay-connected id normalized
                (:none)
                  dispatch! $ :: :relay-channels normalized
              when
                and
                  .none? $ selected-relay-channel
                  = 1 $ .len normalized
                dispatch! $ :: :select-channel $ .unwrap (first normalized)
            , &unit
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost (Option String) Dynamic (-> Unit) (:features :js-ffi)
        'handle-genui-event! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-genui-event! (ws frame)
            let
                request-id $ decode-map-as
                  .unwrap $ get frame :id
                  , 'String
                payload $ field frame :payload
                source $ match payload
                  (:some layout-dsl) (format-cirru-edn layout-dsl)
                  (:none) |
                layout-id $ str |layout- request-id
              try
                let
                    layout-dsl $ match payload
                      (:some value) value
                      (:none) (raise "|genui event requires :payload")
                    layout $ validate-layout layout-dsl
                    ack-payload $ {} (:status :ok) (:layout_id layout-id)
                  dispatch! $ :: :genui-applied request-id layout-id layout layout-dsl source
                  send-genui-ack! ws request-id true ack-payload None
                fn (error)
                  let
                      message $ :message $ host/normalize-error error
                    dispatch! $ :: :genui-failed request-id message source
                    host/console-warn! $ str "|[renderer] validation failed: " message
                    send-genui-ack! ws request-id false nil $ Some message
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost (Map Tag Dynamic) (-> Unit) (:features :js-ffi)
        'handle-relay-message! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-relay-message! (ws raw)
            let
                frame $ decode-map-as (parse-cirru-edn raw) (Map Tag Dynamic)
                kind-name $ .and-then (field frame :kind) protocol-name
                kind $ .unwrap-or kind-name |
                request $ match (field frame :payload)
                  (:some payload) (parse-renderer-request payload)
                  (:none) (RendererRequest :invalid)
                selected $ selected-relay-channel
                pending-storage $ decode-map-as
                  match
                    get-in @*reel $ [] :store :renderer :storage-pending
                    (:ok value) (present-option value)
                    (:err _) None
                  Option $ Map Tag Dynamic
                summary $ if (= kind |hello-ok) "|Relay connected" $ if (= kind |channel-state) "|Channel list updated"
                  if (= kind |warning) (field-or frame :error "|Relay warning")
                    if (= kind |error) (field-or frame :error "|Relay error")
                      if
                        and (= kind |ack) (.some? pending-storage)
                          = (field frame :id)
                            field (.unwrap pending-storage) :request-id
                        str "|Storage " $ field-or (.unwrap pending-storage) :op |request
                        if (= kind |event)
                          match request
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
              dispatch! $ :: :record-relay-message $ ->
                {}
                  :matched? $ if (= kind |event)
                    and (.some? selected)
                      = (field frame :channel) selected
                    , true
                  :summary summary
                  :raw raw
                put-field :kind kind-name
                put-field :channel $ field frame :channel
                put-field :request-id $ field frame :id
              if (= kind |hello-ok)
                handle-channel-state! ws
                  decode-map-as
                    .and-then (get frame :client_id) present-option
                    Option String
                  field-or frame :channels $ []
                if (= kind |channel-state)
                  handle-channel-state! ws None $ field-or frame :channels $ []
                  if (= kind |event)
                    if
                      and (.some? selected)
                        = (field frame :channel) selected
                      match request
                        (:help _) (handle-renderer-event! ws frame)
                        (:skill _) (handle-renderer-event! ws frame)
                        (:status) (handle-renderer-event! ws frame)
                        (:snapshot _) (handle-renderer-event! ws frame)
                        (:layout _) (handle-renderer-event! ws frame)
                        (:node _) (handle-renderer-event! ws frame)
                        (:patch _ _) (handle-renderer-event! ws frame)
                        (:replace _ _) (handle-renderer-event! ws frame)
                        _ $ handle-genui-event! ws frame
                      , |ignored
                    if
                      and (= kind |ack) (.some? pending-storage)
                        = (field frame :id)
                          field (.unwrap pending-storage) :request-id
                      handle-storage-ack! frame
                      if (= kind |warning)
                        host/console-warn! $ decode-map-as (field-or frame :error "|Relay warning") 'String
                        if (= kind |error)
                          dispatch! $ :: :relay-status |error $ field-or frame :error "|Relay error"
                          , |ignored
            , &unit
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost String (-> Unit) (:features :js-ffi)
        'handle-renderer-event! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-renderer-event! (ws frame)
            let
                request-id $ decode-map-as
                  .unwrap $ get frame :id
                  , 'String
                payload $ field frame :payload
                request $ match payload
                  (:some value) (parse-renderer-request value)
                  (:none) (RendererRequest :invalid)
                relay $ decode-map-as
                  match
                    get-in @*reel $ [] :store :relay
                    (:ok value) value
                    (:err error)
                      raise $ str "|Required renderer state path missing: " error
                  Map Tag Dynamic
                renderer $ decode-map-as
                  match
                    get-in @*reel $ [] :store :renderer
                    (:ok value) value
                    (:err error)
                      raise $ str "|Required renderer state path missing: " error
                  Map Tag Dynamic
              host/console-log! $ str "|[renderer] request " $ .unwrap-or payload |
              try
                match request
                  (:help topics)
                    let
                        response-payload $ config/build-help-payload topics
                      send-genui-ack! ws request-id true response-payload None
                  (:skill topics)
                    send-genui-ack! ws request-id true (config/build-skill-payload topics) None
                  (:status)
                    send-genui-ack! ws request-id true (config/build-status-payload relay renderer) None
                  (:snapshot path)
                    if-let
                      layout-dsl $ decode-map-as
                        .and-then (get renderer :layout-dsl) present-option
                        Option $ Map Tag Dynamic
                      let
                          target-node $ layout-node-at-path layout-dsl path
                          response-payload $ {} (:status :ok) (:kind :snapshot)
                            :path $ layout-path-display path
                            :tree $ summarize-layout-node target-node path
                        send-genui-ack! ws request-id true response-payload None
                      send-genui-ack! ws request-id false nil $ Some "|No layout loaded in renderer"
                  (:layout path)
                    if-let
                      layout-dsl $ decode-map-as
                        .and-then (get renderer :layout-dsl) present-option
                        Option $ Map Tag Dynamic
                      let
                          target-node $ layout-node-at-path layout-dsl path
                          response-payload $ put-field
                            {} (:status :ok) (:kind :layout)
                              :path $ layout-path-display path
                              :summary $ summarize-layout-node target-node path
                            , :layout_id $ field renderer :layout-id
                        send-genui-ack! ws request-id true response-payload None
                      send-genui-ack! ws request-id false nil $ Some "|No layout loaded in renderer"
                  (:node path)
                    if-let
                      layout-dsl $ decode-map-as
                        .and-then (get renderer :layout-dsl) present-option
                        Option $ Map Tag Dynamic
                      let
                          target-node $ layout-node-at-path layout-dsl path
                          response-payload $ put-field
                            {} (:status :ok) (:kind :node)
                              :path $ layout-path-display path
                              :dsl target-node
                              :source $ format-cirru-edn target-node
                              :summary $ summarize-layout-node target-node path
                            , :layout_id $ field renderer :layout-id
                        send-genui-ack! ws request-id true response-payload None
                      send-genui-ack! ws request-id false nil $ Some "|No layout loaded in renderer"
                  (:patch path changes)
                    if-let
                      layout-dsl $ decode-map-as
                        .and-then (get renderer :layout-dsl) present-option
                        Option $ Map Tag Dynamic
                      let
                          next-dsl $ merge-layout-node-at-path layout-dsl path changes
                          next-layout $ validate-layout next-dsl
                          next-source $ format-cirru-edn next-dsl
                          next-layout-id $ str |layout- request-id
                          response-payload $ {} (:status :ok) (:kind :patch) (:layout_id next-layout-id)
                            :path $ layout-path-display path
                            :dsl $ layout-node-at-path next-dsl path
                            :summary $ summarize-layout-node (layout-node-at-path next-dsl path) path
                        dispatch! $ :: :layout-mutated request-id next-layout-id next-layout next-dsl next-source
                        send-genui-ack! ws request-id true response-payload None
                      send-genui-ack! ws request-id false nil $ Some "|No layout loaded in renderer"
                  (:replace path next-node)
                    if-let
                      layout-dsl $ decode-map-as
                        .and-then (get renderer :layout-dsl) present-option
                        Option $ Map Tag Dynamic
                      let
                          next-dsl $ replace-layout-node-at-path layout-dsl path $ match next-node
                            (:some value)
                              decode-map-as value $ Map Tag Dynamic
                            (:none) (raise "|Replace request requires map field :node")
                          next-layout $ validate-layout next-dsl
                          next-source $ format-cirru-edn next-dsl
                          next-layout-id $ str |layout- request-id
                          response-payload $ {} (:status :ok) (:kind :replace) (:layout_id next-layout-id)
                            :path $ layout-path-display path
                            :dsl $ layout-node-at-path next-dsl path
                            :summary $ summarize-layout-node (layout-node-at-path next-dsl path) path
                        dispatch! $ :: :layout-mutated request-id next-layout-id next-layout next-dsl next-source
                        send-genui-ack! ws request-id true response-payload None
                      send-genui-ack! ws request-id false nil $ Some "|No layout loaded in renderer"
                  (:invalid)
                    send-genui-ack! ws request-id false nil $ Some "|Unsupported renderer request"
                fn (error)
                  let
                      message $ :message $ host/normalize-error error
                    host/console-warn! $ str "|[renderer] request failed: " message
                    send-genui-ack! ws request-id false nil $ Some message
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost (Map Tag Dynamic) (-> Unit) (:features :js-ffi)
        'handle-storage-ack! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-storage-ack! (frame)
            let
                request-id $ decode-map-as
                  .unwrap $ get frame :id
                  , 'String
                pending $ decode-map-as
                  match
                    get-in @*reel $ [] :store :renderer :storage-pending
                    (:ok value) (present-option value)
                    (:err _) None
                  Option $ Map Tag Dynamic
              when
                and (.some? pending)
                  = (Some request-id)
                    field (.unwrap pending) :request-id
                if (field-or frame :ok false)
                  try
                    let
                        payload $ decode-map-as
                          .unwrap $ get frame :payload
                          Map Tag Dynamic
                        kind $ .unwrap-or
                          .and-then (field payload :kind) protocol-name
                          , |
                      if (= kind |storage-list)
                        dispatch! $ :: :storage-listed request-id $ match (field payload :entries)
                          (:some entries)
                            if (list? entries) entries $ []
                          (:none) ([])
                        if (= kind |storage-save)
                          do
                            dispatch! $ :: :storage-saved request-id payload
                            match @*ws
                              (:some socket) (request-storage-list! socket)
                              (:none) &unit
                          if (= kind |storage-load)
                            let
                                entry $ decode-map-as
                                  .unwrap $ get payload :entry
                                  Map Tag Dynamic
                                layout-dsl $ match (field entry :layout)
                                  (:some value) value
                                  (:none) (raise "|Stored report requires :layout")
                                source $ field-or payload :source $ field-or entry :source (format-cirru-edn layout-dsl)
                                layout-id $ field-or entry :layout_id $ str |saved- (field-or payload :name |)
                                layout $ validate-layout layout-dsl
                              dispatch! $ :: :storage-loaded request-id payload layout-id layout layout-dsl source
                            dispatch! $ :: :storage-failed request-id "|Unsupported storage ack payload"
                    fn (error)
                      let
                          message $ :message $ host/normalize-error error
                        dispatch! $ :: :storage-failed request-id message
                  dispatch! $ :: :storage-failed request-id $ field-or frame :error "|Storage request failed"
            , &unit
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (-> Unit) (:features :js-ffi)
        'internal-storage-channel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def internal-storage-channel |__relay_store__
          :examples $ []
          :schema $ quote String
        'layout-node-at-path $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn layout-node-at-path (node path)
            if (empty? path) node $ let
                children $ field-or node :children $ []
                step $ .unwrap $ first path
              if
                not $ list? children
                raise $ str "|Path " (layout-path-display path) "| requires a parent with :children"
                match (pick-layout-child children step)
                  (:none)
                    raise $ str "|Missing layout node at path " $ layout-path-display path
                  (:some child)
                    recur child $ rest path
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (List Number)
            -> $ Map Tag Dynamic
        'layout-path-display $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn layout-path-display (path)
            if (empty? path) |root $ layout-path-display-iter path |
          :examples $ []
          :schema $ quote $ Fn (List Number) (-> String)
        'layout-path-display-iter $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn layout-path-display-iter (path acc)
            if (empty? path) acc $ let
                step $ str $ .unwrap (first path)
              recur (rest path)
                if (= acc |) step $ str acc |. step
          :examples $ []
          :schema $ quote $ Fn (List Number) String (-> String)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            if config/dev? $ load-console-formatter!
            match
              browser/storage-get $ .unwrap $ get config/site :storage-key
              (:some raw)
                dispatch! $ :: :hydrate-storage $ parse-cirru-edn raw
              (:none) &unit
            render-app!
            add-watch! *reel :changes $ fn (reel prev) (render-app!)
            listen-devtools! |k dispatch!
            browser/add-event-listener! |beforeunload $ fn (event) (persist-storage!)
            browser/add-event-listener! |visibilitychange $ fn (event)
              match (browser/visibility-state)
                (:hidden) (persist-storage!)
                _ &unit
            browser/set-interval! persist-storage! 60000
            match (config/current-url-channel)
              (:some url-channel)
                dispatch! $ :: :select-channel url-channel
              (:none) &unit
            ensure-relay!
            println "|App started."
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'merge-layout-node-at-path $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn merge-layout-node-at-path (node path changes)
            match changes
              (:some value)
                if (map? value)
                  replace-layout-node-at-path node path $ .merge (layout-node-at-path node path)
                    decode-map-as value $ Map Tag Dynamic
                  raise "|Patch request expects map field :changes"
              (:none) (raise "|Patch request expects map field :changes")
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (List Number) (Option Dynamic)
            -> $ Map Tag Dynamic
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def mount-target
            (fn () (hint-fn (Fn (-> respo.dom/DomElement) (:features :js-ffi))) (.unwrap (js-nullish->option (.query-selector (js-cast (browser/document-host) 'respo.dom/DomDocument) |.app))))
          :examples $ []
          :schema $ quote respo.dom/DomElement
        'normalize-layout-path $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-layout-path (path)
            if (nil? path)
              Some $ []
              match (try-decode-map-as path app.main/LayoutPath)
                (:ok checked)
                  match checked
                    (Number n)
                      match (parse-layout-path-segment n)
                        (:some segment)
                          Some $ [] segment
                        (:none) None
                    (List items) (normalize-layout-path-items items)
                    _ $ let
                        raw $ .unwrap $ protocol-name checked
                      if
                        or (= raw |) (= raw |root)
                        Some $ []
                        normalize-layout-path-items $ split raw |.
                (:err _) None
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Option $ List Number
        'normalize-layout-path-items $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-layout-path-items (items)
            .foldl items
              Some $ []
              fn (acc item)
                hint-fn $ Fn
                  Option $ List Number
                  , PathSegment $ ->
                    Option $ List Number
                match acc
                  (:none) None
                  (:some segments)
                    match (parse-layout-path-segment item)
                      (:some segment)
                        Some $ append segments segment
                      (:none) None
          :examples $ []
          :schema $ quote $ Fn (List PathSegment)
            -> $ Option $ List Number
        'normalize-payload-path $ %{} 'CodeEntry
          :doc "|Layout path of a map request payload; a missing or nil :path is the root."
          :code $ quote $ defn normalize-payload-path (payload)
            match (field payload :path)
              (:some path) (normalize-layout-path path)
              (:none)
                Some $ []
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Option $ List Number
        'normalize-renderer-topics $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-renderer-topics (topics)
            if (list? topics)
              .foldl
                assert-type topics $ List Dynamic
                []
                fn (acc item)
                  hint-fn $ Fn (List String) Dynamic $ -> (List String)
                  if
                    or (string? item) (tag? item)
                    append acc $ .unwrap $ protocol-name item
                    , acc
              []
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ List String
        'parse-layout-path-segment $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-layout-path-segment (item)
            match item
              (Number n)
                if (> n 0) (Some n) None
              _ $ let
                  text $ .unwrap $ protocol-name item
                  digits? $ .foldl (split text |) true $ fn (valid? ch)
                    hint-fn $ Fn Bool String $ -> Bool
                    and valid? $ includes? |0123456789 ch
                if
                  and
                    not $ empty? text
                    , digits?
                  match (parse-float text)
                    (:ok n) (Some n)
                    (:err _) None
                  , None
          :examples $ []
          :schema $ quote $ Fn PathSegment
            -> $ Option Number
        'parse-renderer-request $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-renderer-request (payload)
            if (enum? payload)
              match payload
                (:help)
                  RendererRequest :help $ []
                (:help topics)
                  RendererRequest :help $ normalize-renderer-topics topics
                (:skill)
                  RendererRequest :skill $ []
                (:skill topics)
                  RendererRequest :skill $ normalize-renderer-topics topics
                (:status) (RendererRequest :status)
                (:snapshot)
                  RendererRequest :snapshot $ []
                (:snapshot path)
                  if-let
                    normalized $ normalize-layout-path path
                    RendererRequest :snapshot normalized
                    RendererRequest :invalid
                (:layout)
                  RendererRequest :layout $ []
                (:layout path)
                  if-let
                    normalized $ normalize-layout-path path
                    RendererRequest :layout normalized
                    RendererRequest :invalid
                (:node path)
                  if-let
                    normalized $ normalize-layout-path path
                    RendererRequest :node normalized
                    RendererRequest :invalid
                (:patch path changes)
                  if-let
                    normalized $ normalize-layout-path path
                    RendererRequest :patch normalized $ present-option changes
                    RendererRequest :invalid
                (:replace path next-node)
                  if-let
                    normalized $ normalize-layout-path path
                    RendererRequest :replace normalized $ present-option next-node
                    RendererRequest :invalid
                _ $ RendererRequest :invalid
              if (map? payload)
                let
                    op-name $ .unwrap-or
                      .and-then (field payload :op) protocol-name
                      , |
                    topics $ normalize-renderer-topics $ field-or payload :topics ([])
                  match op-name
                    |help $ RendererRequest :help topics
                    |skill $ RendererRequest :skill topics
                    |status $ RendererRequest :status
                    |snapshot $ let
                        normalized $ normalize-payload-path payload
                      if (.some? normalized)
                        RendererRequest :snapshot $ .unwrap normalized
                        RendererRequest :invalid
                    |layout $ let
                        normalized $ normalize-payload-path payload
                      if (.some? normalized)
                        RendererRequest :layout $ .unwrap normalized
                        RendererRequest :invalid
                    |node $ let
                        normalized $ normalize-payload-path payload
                      if (.some? normalized)
                        RendererRequest :node $ .unwrap normalized
                        RendererRequest :invalid
                    |patch $ let
                        normalized $ normalize-payload-path payload
                      if (.some? normalized)
                        RendererRequest :patch (.unwrap normalized) (field payload :changes)
                        RendererRequest :invalid
                    |replace $ let
                        normalized $ normalize-payload-path payload
                      if (.some? normalized)
                        RendererRequest :replace (.unwrap normalized)
                          .or-else (field payload :node)
                            fn () $ field payload :dsl
                        RendererRequest :invalid
                    _ $ RendererRequest :invalid
                RendererRequest :invalid
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> RendererRequest)
        'persist-storage! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-storage! ()
            println "|Saved at" $ :iso $ host/date-now-snapshot
            .set-item! (browser/window-local-storage)
              .unwrap $ get config/site :storage-key
              format-cirru-edn $ .unwrap $ get @*reel :store
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'pick-layout-child $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn pick-layout-child (children position)
            if (list? children)
              let
                  items children
                if
                  or (<= position 0) (empty? items)
                  , None $ if (= position 1)
                    Some $ decode-map-as
                      .unwrap $ first items
                      Map Tag Dynamic
                    recur (rest items) (dec position)
              , None
          :examples $ []
          :schema $ quote $ Fn Dynamic Number
            -> $ Option $ Map Tag Dynamic
        'protocol-name $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn protocol-name (x)
            cond
                string? x
                Some x
              (tag? x)
                Some $ to-string x
              true None
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Option String
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if (nil? build-errors)
              do (remove-watch! *reel :changes) (clear-cache!)
                add-watch! *reel :changes $ fn (reel prev) (render-app!)
                reset! *reel $ decode-map-as (refresh-reel @*reel schema/store updater) (Map Tag Dynamic)
                ensure-relay!
                hud! |ok~ |Ok
              hud! |error build-errors
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render! mount-target (comp-container @*reel) dispatch!
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'replace-layout-node-at-path $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn replace-layout-node-at-path (node path next-node)
            if (empty? path) next-node $ let
                children $ field-or node :children $ []
                step $ .unwrap $ first path
              if
                not $ list? children
                raise $ str "|Path " (layout-path-display path) "| requires a parent with :children"
                if
                  .none? $ pick-layout-child children step
                  raise $ str "|Missing layout node at path " $ layout-path-display path
                  assoc node :children $ map-indexed
                    decode-map-as children $ List $ Map Tag Dynamic
                    fn (idx child)
                      hint-fn $ Fn Number (Map Tag Dynamic)
                        -> $ Map Tag Dynamic
                      if
                        = (inc idx) step
                        replace-layout-node-at-path child (rest path) next-node
                        , child
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (List Number) (Map Tag Dynamic)
            -> $ Map Tag Dynamic
        'request-storage-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn request-storage-list! (ws)
            match (selected-relay-channel)
              (:some channel)
                let
                    request-id $ str |storage-list- $ host/now-ms
                  dispatch! $ :: :storage-pending request-id |list
                  send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                    :payload $ {} (:op :list) (:channel channel)
              (:none)
                dispatch! $ :: :storage-failed nil "|Select a channel before browsing saved reports"
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost (-> Unit) (:features :js-ffi)
        'request-storage-load! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn request-storage-load! (ws name)
            match (selected-relay-channel)
              (:some channel)
                let
                    request-id $ str |storage-load- $ host/now-ms
                  dispatch! $ :: :storage-pending request-id |load
                  send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                    :payload $ {} (:op :load) (:channel channel) (:name name)
              (:none)
                dispatch! $ :: :storage-failed nil "|Select a channel before loading saved reports"
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost String (-> Unit) (:features :js-ffi)
        'request-storage-save! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn request-storage-save! (ws)
            let
                relay $ decode-map-as
                  match
                    get-in @*reel $ [] :store :relay
                    (:ok value) value
                    (:err error)
                      raise $ str "|Required renderer state path missing: " error
                  Map Tag Dynamic
                renderer $ decode-map-as
                  match
                    get-in @*reel $ [] :store :renderer
                    (:ok value) value
                    (:err error)
                      raise $ str "|Required renderer state path missing: " error
                  Map Tag Dynamic
              if
                and (field-is? relay :selected-channel non-nil?) (field-is? renderer :layout-dsl non-nil?)
                let
                    request-id $ str |storage-save- $ host/now-ms
                    entry $ build-saved-report-entry relay renderer
                    file-name $ str (field-or relay :selected-channel |report) |- $ field-or renderer :layout-id (field-or renderer :last-request |snapshot)
                  dispatch! $ :: :storage-pending request-id |save
                  send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                    :payload $ {} (:op :save)
                      :channel $ .unwrap $ field relay :selected-channel
                      :name file-name
                      :entry entry
                dispatch! $ :: :storage-failed nil "|A validated layout is required before saving a report"
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost (-> Unit) (:features :js-ffi)
        'selected-relay-channel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn selected-relay-channel ()
            match
              data-view $ .unwrap-or
                get-in @*reel $ [] :store :relay :selected-channel
                , nil
              (:nil) None
              (:string channel) (Some channel)
              _ $ raise "|Renderer selected channel must be a string or nil"
          :examples $ []
          :schema $ quote $ Fn
            -> $ Option String
        'send-genui-ack! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn send-genui-ack! (ws request-id ok? payload error-message)
            send-relay-frame! ws $ put-field
              {} (:kind :ack) (:id request-id) (:ok ok?) (:payload payload)
              , :error error-message
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost String Bool Dynamic (Option String) (-> Unit) (:features :js-ffi)
        'send-relay-frame! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn send-relay-frame! (ws frame)
            browser/web-socket-send! ws $ format-cirru-edn frame
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost (Map Tag Dynamic) (-> Unit) (:features :js-ffi)
        'summarize-layout-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn summarize-layout-node (node path)
            let
                text $ match (field node :text)
                  (:some value)
                    if (string? value)
                      Some $ assert-type value String
                      , None
                  (:none) None
                children $ if (field-is? node :children list?)
                  decode-map-as
                    field-or node :children $ []
                    List $ Map Tag Dynamic
                  []
                base $ assert-type
                  put-field
                    {}
                      :path $ layout-path-display path
                      :child-count $ .len children
                    , :type $ field node :type
                  Map Tag Dynamic
                meta $ assert-type
                  match (field-or node :type |)
                    |card $ put-field ({}) :title text
                    |text $ put-field ({}) :text $ .and-then text
                      fn (value)
                        first $ split-lines value
                    |badge $ put-field ({}) :text text
                    |button $ put-field ({}) :text text
                    |input $ -> ({})
                      put-field :name $ field node :name
                      put-field :placeholder $ field node :placeholder
                    |markdown $ {} $ :lines
                      .len $ split-lines $ .unwrap-or text |
                    |mermaid $ {} $ :lines
                      .len $ split-lines $ .unwrap-or text |
                    |chart $ {}
                      :kind $ field-or node :kind |bar
                      :title $ field-or node :title |
                      :series-count $ .len $ decode-map-as
                        field-or node :series $ []
                        List Dynamic
                    |math $ put-field
                      {} $ :display $ field-or node :display |inline
                      , :expr-tag $ first
                        decode-map-as
                          field-or node :expr $ []
                          List Dynamic
                    _ $ {}
                  Map Tag Dynamic
              .merge base $ if
                > (.len children) 0
                assoc meta :children $ map-indexed children $ fn (idx child)
                  hint-fn $ Fn Number (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  summarize-layout-node child $ append path $ inc idx
                , meta
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (List Number)
            -> $ Map Tag Dynamic
        'sync-selected-channel! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn sync-selected-channel! (ws)
            let
                client-id $ .unwrap-or
                  get-in @*reel $ [] :store :relay :client-id
                  , nil
                selected $ selected-relay-channel
                channels $ match selected
                  (:some channel) ([] channel internal-storage-channel)
                  (:none) ([] internal-storage-channel)
              send-relay-frame! ws $ {} (:kind :hello) (:role :receiver) (:client_id client-id) (:channels channels)
          :examples $ []
          :schema $ quote $ Fn browser/WebSocketHost (-> Unit) (:features :js-ffi)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            respo.core :refer $ render! clear-cache!
            app.comp.container :refer $ comp-container validate-layout present-option
            app.field :refer $ field field-is? field-or put-field
            app.updater :refer $ updater
            app.schema :as schema
            reel.util :refer $ listen-devtools!
            reel.core :refer $ reel-updater refresh-reel
            reel.schema :as reel-schema
            app.config :as config
            |./calcit.build-errors :default build-errors
            |bottom-tip :default hud!
            js-ffi.shared :as host
            js-ffi.browser :as browser
    'app.schema $ %{} 'FileEntry
      :defs $ {}
        'DispatchOp $ %{} 'CodeEntry (:doc "|Respo 入口事件合同，容纳应用和 Reel 控制事件；代表值不发送。")
          :code $ quote $ def DispatchOp (:: :unhandled)
          :examples $ []
          :schema $ quote AnyEnum
        'store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            {}
              :states $ {} $ :cursor ([])
              :relay $ {} (:status |idle) (:client-id nil) (:last-error nil) (:selected-channel nil)
                :channels $ []
              :renderer $ {} (:layout nil) (:layout-dsl nil) (:layout-id nil) (:layout-source |) (:last-request nil) (:last-error nil)
                :history $ []
                :selected-history nil
                :drawer-view |history
                :channel-cache $ {}
                :storage-status |idle
                :storage-error nil
                :storage-pending nil
                :storage-entries $ []
                :selected-storage nil
                :workspace-entry nil
          :examples $ []
          :schema $ quote $ Map Tag Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.updater $ %{} 'FileEntry
      :defs $ {}
        'cache-renderer-channel-state $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn cache-renderer-channel-state (renderer channel)
            match channel
              (:none) renderer
              (:some channel-name)
                let
                    cache $ decode-map-as
                      field-or renderer :channel-cache $ {}
                      Map String $ Map Tag Dynamic
                  assoc renderer :channel-cache $ assoc cache channel-name $ pick-renderer-channel-state renderer
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (Option String)
            -> $ Map Tag Dynamic
        'pick-renderer-channel-state $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn pick-renderer-channel-state (renderer) (select-keys renderer renderer-channel-keys)
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic)
            -> $ Map Tag Dynamic
        'renderer-channel-default $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def renderer-channel-default
            {} (:layout nil) (:layout-dsl nil) (:layout-id nil) (:layout-source |) (:last-request nil) (:last-error nil) (:storage-status |idle) (:storage-error nil) (:storage-pending nil)
              :storage-entries $ []
              :selected-storage nil
              :workspace-entry nil
          :examples $ []
          :schema $ quote $ Map Tag Dynamic
        'renderer-channel-keys $ %{} 'CodeEntry
          :doc "|Renderer slots cached per channel; `renderer-channel-default` gives each one a value."
          :code $ quote $ def renderer-channel-keys
            [] :layout :layout-dsl :layout-id :layout-source :last-request :last-error :storage-status :storage-error :storage-pending :storage-entries :selected-storage :workspace-entry
          :examples $ []
          :schema $ quote $ List Tag
        'restore-renderer-channel-state $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn restore-renderer-channel-state (renderer channel)
            let
                next-state $ let
                    cache $ decode-map-as
                      field-or renderer :channel-cache $ {}
                      Map String $ Map Tag Dynamic
                    cached $ match channel
                      (:none)
                        assert-type ({}) (Map Tag Dynamic)
                      (:some channel-name)
                        .unwrap-or (get cache channel-name)
                          assert-type ({}) (Map Tag Dynamic)
                  restore-renderer-layout $ .merge renderer-channel-default cached
              .merge renderer $ select-keys next-state renderer-channel-keys
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (Option String)
            -> $ Map Tag Dynamic
        'restore-renderer-layout $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn restore-renderer-layout (renderer)
            match (field renderer :layout-dsl)
              (:some dsl)
                assoc renderer :layout $ validate-layout dsl
              (:none)
                put-field renderer :layout $ decode-map-as
                  .and-then (get renderer :layout) present-option
                  Option app.comp.container/LayoutNode
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic)
            -> $ Map Tag Dynamic
        'update-renderer $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn update-renderer (store f)
            let
                renderer $ decode-map-as
                  field-or store :renderer $ {}
                  Map Tag Dynamic
              assoc store :renderer $ f renderer
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic)
            Fn (Map Tag Dynamic)
              -> $ Map Tag Dynamic
            -> $ Map Tag Dynamic
        'updater $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            match op
              (:states cursor s)
                assoc store :states $ update-state-tree
                  .unwrap-or (get store :states) ({})
                  decode-map-as cursor $ List respo.schema/CoordKey
                  , s
              (:hydrate-storage data)
                update-renderer
                  decode-map-as data $ Map Tag Dynamic
                  , restore-renderer-layout
              (:relay-connected client-id channels)
                -> store
                  assoc-in ([] :relay :status) |ready
                  assoc-in ([] :relay :client-id) client-id
                  assoc-in ([] :relay :channels) channels
                  assoc-in ([] :relay :last-error) nil
              (:relay-channels channels)
                assoc-in store ([] :relay :channels) channels
              (:select-channel channel)
                let
                    relay $ decode-map-as
                      field-or store :relay $ {}
                      Map Tag Dynamic
                    current-channel $ decode-map-as
                      .and-then (get relay :selected-channel) present-option
                      Option String
                    prev-renderer $ decode-map-as
                      field-or store :renderer $ {}
                      Map Tag Dynamic
                    cached-renderer $ cache-renderer-channel-state prev-renderer current-channel
                  -> store
                    assoc :relay $ assoc relay :selected-channel channel
                    assoc :renderer $ restore-renderer-channel-state cached-renderer $ if (nil? channel) None
                      Some $ decode-map-as channel 'String
              (:relay-status status message)
                -> store
                  assoc-in ([] :relay :status) status
                  assoc-in ([] :relay :last-error) message
              (:record-relay-message entry)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  let
                      prev-renderer renderer
                      prev-history $ match
                        data-view $ field-or prev-renderer :history $ []
                        (:list history-items) history-items
                        _ $ []
                    -> prev-renderer
                      assoc :history $ append prev-history entry
                      assoc :selected-history entry
              (:select-history entry)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  assoc renderer :selected-history entry
              (:open-history-drawer)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  assoc renderer :drawer-view |history
              (:open-library-drawer)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  assoc renderer :drawer-view |library
              (:request-storage-list) store
              (:save-current-report) store
              (:load-stored-report _) store
              (:load-workspace-report)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  let
                      prev-renderer renderer
                    match
                      decode-map-as
                        .and-then (get prev-renderer :workspace-entry) present-option
                        Option $ Map Tag Dynamic
                      (:some current-entry)
                        -> prev-renderer (assoc :selected-storage current-entry)
                          put-field :layout $ .map (field current-entry :layout-dsl) validate-layout
                          put-field :layout-dsl $ field current-entry :layout-dsl
                          put-field :layout-id $ field current-entry :layout_id
                          put-field :layout-source $ field current-entry :source
                          put-field :last-request $ field current-entry :request_id
                          assoc :last-error nil
                          assoc :storage-status |workspace
                          assoc :storage-error nil
                      (:none) prev-renderer
              (:storage-pending request-id op-name)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  -> renderer
                    assoc :storage-pending $ {} (:request-id request-id) (:op op-name)
                    assoc :storage-status |working
                    assoc :storage-error nil
              (:storage-saved request-id entry)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  -> renderer (assoc :storage-pending nil) (assoc :storage-status |saved) (assoc :storage-error nil) (assoc :selected-storage entry)
              (:storage-listed request-id entries)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  -> renderer (assoc :storage-pending nil) (assoc :storage-status |ready) (assoc :storage-error nil) (assoc :storage-entries entries)
              (:storage-loaded request-id entry layout-id layout layout-dsl source)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  -> renderer (assoc :storage-pending nil) (assoc :storage-status |loaded) (assoc :storage-error nil) (assoc :selected-storage entry) (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil)
              (:storage-failed request-id message)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  -> renderer (assoc :storage-pending nil) (assoc :storage-status |error) (assoc :storage-error message)
              (:genui-applied request-id layout-id layout layout-dsl source)
                let
                    channel $ field
                      field-or store :relay $ {}
                      , :selected-channel
                    entry $ ->
                      assert-type
                        {} $ :kind :workspace-report
                        Map Tag Dynamic
                      put-field :channel channel
                      assoc :name $ str (.unwrap-or channel |workspace) "| / current workspace"
                      assoc :path "|Local workspace snapshot. Not saved in library."
                      assoc :layout_id layout-id
                      assoc :request_id request-id
                      assoc :layout-data layout
                      assoc :layout-dsl layout-dsl
                      assoc :source source
                  update-renderer store $ fn (renderer)
                    hint-fn $ Fn (Map Tag Dynamic)
                      -> $ Map Tag Dynamic
                    -> renderer (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil) (assoc :workspace-entry entry) (assoc :selected-storage entry) (assoc :storage-status |workspace) (assoc :storage-error nil)
              (:genui-failed request-id message source)
                update-renderer store $ fn (renderer)
                  hint-fn $ Fn (Map Tag Dynamic)
                    -> $ Map Tag Dynamic
                  -> renderer (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error message)
              (:layout-mutated request-id layout-id layout layout-dsl source)
                let
                    channel $ field
                      field-or store :relay $ {}
                      , :selected-channel
                    entry $ ->
                      assert-type
                        {} $ :kind :workspace-report
                        Map Tag Dynamic
                      put-field :channel channel
                      assoc :name $ str (.unwrap-or channel |workspace) "| / current workspace"
                      assoc :path "|Local workspace snapshot. Not saved in library."
                      assoc :layout_id layout-id
                      assoc :request_id request-id
                      assoc :layout-data layout
                      assoc :layout-dsl layout-dsl
                      assoc :source source
                  update-renderer store $ fn (renderer)
                    hint-fn $ Fn (Map Tag Dynamic)
                      -> $ Map Tag Dynamic
                    -> renderer (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil) (assoc :workspace-entry entry) (assoc :selected-storage entry) (assoc :storage-status |workspace) (assoc :storage-error nil)
              _ $ do (eprintln "|unknown op:" op) store
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) Dynamic String Number
            -> $ Map Tag Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require
            respo.cursor :refer $ update-state-tree
            app.comp.container :refer $ validate-layout present-option
            app.field :refer $ field field-is? field-or put-field
