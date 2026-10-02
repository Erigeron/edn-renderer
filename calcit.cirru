
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |alerts.calcit/ |js-ffi/
      :type-slots $ {}
  :files $ {}
    'app.comp.container $ %{} 'FileEntry
      :defs $ {}
        '*mermaid-ready $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *mermaid-ready false
          :examples $ []
          :schema $ :: 'Ref 'Bool
        '*rendered-svgs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *rendered-svgs ({})
          :examples $ []
          :schema $ :: 'Ref $ :: 'Map 'String 'app.comp.container/MermaidCache
        'EChartHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait EChartHost
            .set-option! $ :: 'Fn $ {}
              :args $ [] 'app.comp.container/EChartHost 'JsObject 'Bool
              :return 'Unit
            .dispose! $ :: 'Fn $ {}
              :args $ [] 'app.comp.container/EChartHost
              :return 'Unit
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} (:dispose! |dispose) (:set-option! |setOption)
          :schema $ :: 'Trait
        'LayoutNode $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def LayoutNode
            defenum LayoutNode
              :column $ :: 'List 'app.comp.container/LayoutNode
              :row $ :: 'List 'app.comp.container/LayoutNode
              :card (:: 'Option 'String) (:: 'List 'app.comp.container/LayoutNode)
              :text 'String
              :badge 'String
              :divider
              :button 'String
              :input 'Dynamic 'Dynamic 'Dynamic
              :markdown 'String
              :mermaid 'String
              :chart 'Dynamic 'Dynamic $ :: 'List $ :: 'Map 'Tag 'Dynamic
              :math (:: 'List 'Dynamic) 'String
          :examples $ []
          :schema $ :: 'Dynamic
        'MathElementHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait MathElementHost (:inner-html 'String)
            .set-attribute! $ :: 'Fn $ {}
              :args $ [] 'app.comp.container/MathElementHost 'String 'String
              :return 'Unit
            .append-child! $ :: 'Fn $ {}
              :args $ [] 'app.comp.container/MathElementHost 'JsObject
              :return 'JsObject
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} (:append-child! |appendChild) (:inner-html |innerHTML) (:set-attribute! |setAttribute)
            :writable $ #{} :inner-html
          :schema $ :: 'Trait
        'MermaidCache $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum MermaidCache (:rendering) (:failed) (:ready 'String)
          :examples $ []
          :schema $ :: 'Enum
        'MermaidHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait MermaidHost
            .initialize! $ :: 'Fn $ {}
              :args $ [] 'app.comp.container/MermaidHost 'JsObject
              :return 'Unit
            .render $ :: 'Fn $ {}
              :args $ [] 'app.comp.container/MermaidHost 'String 'String
              :return 'js-ffi.shared/PromiseHost
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} $ :initialize! |initialize
          :schema $ :: 'Trait
        'MermaidPayload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct MermaidPayload (:empty? 'Bool) (:source 'String) (:graph-id 'String)
          :examples $ []
          :schema $ :: 'Enum
        'MermaidResultHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait MermaidResultHost (:svg 'String)
            :bind-functions $ :: 'JsNullish $ :: 'Fn
              {}
                :args $ [] 'js-ffi.browser/DomElementHost
                :return 'Unit
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
            :names $ {} $ :bind-functions |bindFunctions
          :schema $ :: 'Trait
        'append-mathml-child! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn append-mathml-child! (el child path)
            do
              if (string? child)
                el .append-child! $ unsafe-coerce (js/document.createTextNode child) JsObject
                if (number? child)
                  el .append-child! $ unsafe-coerce
                    js/document.createTextNode $ str child
                    , JsObject
                  if (list? child)
                    el .append-child! $ unsafe-coerce
                      build-mathml-element
                        assert-type child $ :: 'List 'Dynamic
                        , path
                      , JsObject
                    raise $ str path "| invalid MathML child, expected string, number, or list"
              , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'app.comp.container/MathElementHost 'Dynamic 'String
            :features $ #{} :js-ffi
        'build-echarts-option $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-echarts-option (series kind title)
            let
                normalized-kind $ if (string? kind) kind |bar
                normalized-series $ if (list? series) series $ []
                names $ -> normalized-series .to-list $ map
                  fn (item)
                    assert-type (&map:get item :label) 'String
                values $ -> normalized-series .to-list $ map
                  fn (item)
                    assert-type (&map:get item :value) 'Number
                title-part $ if
                  or (nil? title) (= title |)
                  {}
                  {} $ :title $ {} (:text title)
                category-axis $ {} (:type |category) (:data names)
                  :axisLabel $ {} (:interval 0) (:rotate 20) (:hideOverlap false)
                grid-part $ {} $ :grid
                  {} (:left 48) (:right 24) (:top 72) (:bottom 72) (:containLabel true)
                base $ merge
                  assert-type
                    {} (:animation false)
                      :tooltip $ {}
                    :: 'Map 'Tag 'Dynamic
                  assert-type title-part $ :: 'Map 'Tag 'Dynamic
                  assert-type grid-part $ :: 'Map 'Tag 'Dynamic
              case-default normalized-kind
                merge
                  assert-type base $ :: 'Map 'Tag 'Dynamic
                  assert-type
                    {} (:xAxis category-axis)
                      :yAxis $ {} $ :type |value
                      :series $ [] $ {} (:type |bar) (:data values)
                    :: 'Map 'Tag 'Dynamic
                |line $ merge
                  assert-type base $ :: 'Map 'Tag 'Dynamic
                  assert-type
                    {} (:xAxis category-axis)
                      :yAxis $ {} $ :type |value
                      :series $ [] $ {} (:type |line) (:data values)
                    :: 'Map 'Tag 'Dynamic
                |pie $ merge
                  assert-type base $ :: 'Map 'Tag 'Dynamic
                  assert-type
                    {} $ :series $ []
                      {} (:type |pie)
                        :data $ -> normalized-series .to-list $ map
                          fn (item)
                            {}
                              :name $ assert-type (&map:get item :label) 'String
                              :value $ assert-type (&map:get item :value) 'Number
                    :: 'Map 'Tag 'Dynamic
                |scatter $ merge
                  assert-type base $ :: 'Map 'Tag 'Dynamic
                  assert-type
                    {} (:xAxis category-axis)
                      :yAxis $ {} $ :type |value
                      :series $ [] $ {} (:type |scatter) (:data values)
                    :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ []
              :: 'List $ :: 'Map 'Tag 'Dynamic
              , 'Dynamic 'Dynamic
            :return $ :: 'Map 'Tag 'Dynamic
        'build-mathml-element $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-mathml-element (expr path)
            let
                tag-name $ assert-type
                  .unwrap $ first expr
                  , 'String
                el $ unsafe-coerce (browser/create-element-ns mathml-namespace tag-name) MathElementHost
              foldl (rest expr) &unit $ fn (acc child)
                hint-fn $ {}
                  :args $ [] 'Unit 'Dynamic
                  :return 'Unit
                append-mathml-child! el child $ str path |/ tag-name
              , el
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.comp.container/MathElementHost)
            :args $ [] (:: 'List 'Dynamic) 'String
            :features $ #{} :js-ffi
        'build-mathml-root $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-mathml-root (expr display)
            let
                root $ unsafe-coerce (browser/create-element-ns mathml-namespace |math) MathElementHost
              root .set-attribute! |display $ math-display-value display
              root .append-child! $ unsafe-coerce (build-mathml-element expr |math) JsObject
              , root
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.comp.container/MathElementHost)
            :args $ [] (:: 'List 'Dynamic) 'String
            :features $ #{} :js-ffi
        'build-mermaid-render-payload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-mermaid-render-payload (text)
            if
              = (trim text) |
              &%{} MermaidPayload :empty? true :source | :graph-id |
              &%{} MermaidPayload :empty? false :source text :graph-id $ str |mermaid- (count text) |- $ count (split-lines text)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.comp.container/MermaidPayload)
            :args $ [] 'String
        'comp-chart-block $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-chart-block (series kind title)
            let
                option $ build-echarts-option series kind title
              [] (effect-echarts option)
                div $ {} (:class-name |echarts-host)
                  :style $ {} (:width |100%) (:height |300px)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ []
              :: 'List $ :: 'Map 'Tag 'Dynamic
              , 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (reel)
            let
                store $ assert-type
                  .unwrap $ get reel :store
                  :: 'Map 'Tag 'Dynamic
                states $ assert-type
                  .unwrap $ get store :states
                  :: 'Map 'Tag 'Dynamic
                relay $ assert-type
                  or (&map:get store :relay) ({})
                  :: 'Map 'Tag 'Dynamic
                renderer $ assert-type
                  or (&map:get store :renderer) ({})
                  :: 'Map 'Tag 'Dynamic
                drawer-open? $ .unwrap-or
                  get-in states $ [] :drawer :data :show?
                  , false
                selected-channel $ &map:get relay :selected-channel
                channels $ if
                  list? $ &map:get relay :channels
                  assert-type (&map:get relay :channels) (:: 'List 'String)
                  []
                history $ if
                  list? $ &map:get renderer :history
                  assert-type (&map:get renderer :history) (:: 'List 'Dynamic)
                  []
                selected-history $ &map:get renderer :selected-history
                storage-status $ or (&map:get renderer :storage-status) |idle
                storage-error $ &map:get renderer :storage-error
                storage-entries $ if
                  list? $ &map:get renderer :storage-entries
                  assert-type (&map:get renderer :storage-entries) (:: 'List 'Dynamic)
                  []
                selected-storage $ &map:get renderer :selected-storage
                workspace-entry $ &map:get renderer :workspace-entry
                detail-status $ if
                  and (some? selected-storage)
                    = (&map:get selected-storage :kind) :workspace-report
                  , |workspace storage-status
                drawer-view $ or (&map:get renderer :drawer-view) |history
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
                              <> $ str "|Messages: " $ count history
                            if (some? selected-channel)
                              div
                                {} $ :style $ {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                <> $ str "|Channel: " selected-channel
                            div
                              {} $ :style $ {} (:padding "|2px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                              <> $ str "|Reports: " $ count storage-entries
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
                                match
                                  optionally $ assert-type workspace-entry $ :: 'Optional (:: 'Map 'Tag 'Dynamic)
                                  (:some item)
                                    let
                                        active? $ if (some? selected-storage)
                                          =
                                            &map:get
                                              assert-type selected-storage $ :: 'Map 'Tag 'Dynamic
                                              , :kind
                                            , :workspace-report
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
                                          {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                          <> $ or (&map:get item :name) "|Current workspace"
                                        div
                                          {} $ :style $ {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                          <> $ or (&map:get item :path) |
                                  (:none) nil
                                if
                                  > (count storage-entries) 0
                                  list->
                                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 6)
                                    -> storage-entries .to-list $ map-indexed $ fn (idx item)
                                      let
                                          active? $ match
                                            optionally $ assert-type selected-storage $ :: 'Optional (:: 'Map 'Tag 'Dynamic)
                                            (:some current)
                                              if
                                                = (&map:get current :kind) :workspace-report
                                                , false $ = (&map:get item :name) (&map:get current :name)
                                            (:none) false
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
                                              d! $ :: :load-stored-report $ &map:get item :name
                                          div
                                            {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                            <> $ or (&map:get item :name) "|Saved report"
                                          div
                                            {} $ :style $ {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                            <> $ or (&map:get item :path) |
                                  div
                                    {} $ :style $ {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|No saved reports for current channel yet."
                              if
                                > (count history) 0
                                list->
                                  {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 6) (:max-height "|calc(100vh - 180px)") (:overflow |auto)
                                  -> history .to-list $ map-indexed $ fn (idx item)
                                    let
                                        active? $ match
                                          optionally $ assert-type selected-history $ :: 'Optional (:: 'Map 'Tag 'Dynamic)
                                          (:some current)
                                            = (&map:get item :raw) (&map:get current :raw)
                                          (:none) false
                                        meta-channel $ or (&map:get item :channel) |session
                                        meta-request $ or (&map:get item :request-id) |-
                                      [] idx $ div
                                        {}
                                          :style $ {} (:padding "|8px 10px") (:border-radius 12)
                                            :border $ if active? "|1px solid #8a8f98" "|1px solid #d7d7cf"
                                            :background-color $ if active? |#eef1f4 |#ffffff
                                            :cursor |pointer
                                            :display |flex
                                            :flex-direction |column
                                            :gap 4
                                            :opacity $ if (&map:get item :matched?) |1 |0.72
                                          :on-click $ fn (e d!)
                                            d! $ :: :select-history item
                                        div
                                          {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#1f2933)
                                          <> $ or (&map:get item :summary) |Message
                                        div
                                          {} $ :style $ {} (:font-size 11) (:line-height |1.5) (:color |#6b7280)
                                          <> $ str
                                            or (&map:get item :kind) |unknown
                                            , "| / " meta-channel "| / " meta-request
                                div
                                  {} $ :style $ {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                  <> "|No relay messages yet."
                          div
                            {} $ :style $ {} (:flex |1) (:min-width 280) (:display |flex) (:flex-direction |column) (:gap 8)
                            div
                              {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#4b5563)
                              <> |Detail
                            if (= drawer-view |library)
                              match
                                optionally $ assert-type selected-storage $ :: 'Optional (:: 'Map 'Tag 'Dynamic)
                                (:some item)
                                  div
                                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 8)
                                    div
                                      {} $ :style $ {} (:font-size 14) (:font-weight |700) (:color |#1f2933)
                                      <> $ or (&map:get item :name) "|Saved report"
                                    div
                                      {} $ :style $ {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                                      div
                                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Status: " detail-status
                                      if (some? selected-channel)
                                        div
                                          {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                          <> $ str "|Channel: " selected-channel
                                    textarea $ {}
                                      :value $ format-cirru-edn $ {}
                                        :name $ or (&map:get item :name) |-
                                        :path $ or (&map:get item :path) |-
                                        :status detail-status
                                      :read-only true
                                      :spell-check false
                                      :placeholder "|Library item detail"
                                      :style $ {} (:width |100%) (:min-height "|calc(100vh - 320px)") (:padding 12) (:box-sizing |border-box) (:border-radius 14) (:border "|1px solid #d7d7cf") (:background-color |#ffffff) (:font-family |Monaco) (:font-size 12) (:line-height |1.6) (:resize |vertical)
                                (:none)
                                  div
                                    {} $ :style $ {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|Click the current workspace snapshot or a saved report to load it into the preview."
                              match
                                optionally $ assert-type selected-history $ :: 'Optional (:: 'Map 'Tag 'Dynamic)
                                (:some item)
                                  div
                                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 8)
                                    div
                                      {} $ :style $ {} (:font-size 14) (:font-weight |700) (:color |#1f2933)
                                      <> $ or (&map:get item :summary) |Message
                                    div
                                      {} $ :style $ {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                                      div
                                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Kind: " $ or (&map:get item :kind) |unknown
                                      div
                                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Channel: " $ or (&map:get item :channel) |session
                                      div
                                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#ffffff) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                                        <> $ str "|Request: " $ or (&map:get item :request-id) |-
                                    if (&map:get item :matched?)
                                      div $ {}
                                      div
                                        {} $ :style $ {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#f4f4f1) (:border "|1px solid #deded8") (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                        <> "|This message did not match the current channel filter."
                                    textarea $ {}
                                      :value $ or (&map:get item :raw) |
                                      :read-only true
                                      :spell-check false
                                      :placeholder "|Relay frame detail"
                                      :style $ {} (:width |100%) (:min-height "|calc(100vh - 320px)") (:padding 12) (:box-sizing |border-box) (:border-radius 14) (:border "|1px solid #d7d7cf") (:background-color |#ffffff) (:font-family |Monaco) (:font-size 12) (:line-height |1.6) (:resize |vertical)
                                (:none)
                                  div
                                    {} $ :style $ {} (:padding "|10px 12px") (:border-radius 12) (:border "|1px dashed #d7d7cf") (:background-color |#fcfcfa) (:font-size 12) (:line-height |1.6) (:color |#6b7280)
                                    <> "|Click a message to inspect its raw relay frame."
                        when dev? $ comp-reel (>> states :reel) reel $ {}
                help-alert $ use-alert (>> states :help)
                  {} $ :text "|Use History to inspect recent relay frames and the raw Cirru EDN being rendered."
              do
                effect-page-title $ if (nil? selected-channel) (Option :none)
                  Option :some $ assert-type selected-channel 'String
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
                        if (some? selected-channel)
                          <> $ str "|Channel: " selected-channel
                          <> "|No channel"
                    div
                      {} $ :style $ {} (:display |flex) (:gap 6) (:flex-wrap |wrap) (:align-items |center) (:justify-content |flex-end)
                      div
                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#f4f4f1) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                        <> $ str "|Relay: " $ or (&map:get relay :status) |idle
                      div
                        {} $ :style $ {} (:padding "|3px 8px") (:border-radius 999) (:background-color |#f4f4f1) (:border "|1px solid #d7d7cf") (:font-size 11) (:color |#4b5563)
                        if
                          some? $ &map:get renderer :layout-id
                          <> |Ready
                          <> |Waiting
                      button $ {} (:class-name css/button)
                        :inner-text $ str "|History " $ count history
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
                        :disabled $ nil? $ &map:get renderer :layout-dsl
                        :style $ {} (:padding "|5px 8px") (:font-size 11)
                        :on-click $ fn (e d!)
                          d! $ :: :save-current-report
                      button $ {} (:class-name css/button) (:inner-text |Tips)
                        :style $ {} (:padding "|5px 8px") (:font-size 11)
                        :on-click $ fn (e d!) (.show help-alert d! nil)
                  match
                    optionally $ assert-type (&map:get relay :last-error) (:: 'Optional 'String)
                    (:some relay-error)
                      div
                        {} $ :style $ {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff1ec) (:border "|1px solid #f0c4b4") (:font-size 12) (:line-height |1.5) (:color |#a23f1a) (:margin-top 8)
                        <> $ str "|Relay error: " relay-error
                    (:none) nil
                  match
                    optionally $ assert-type (&map:get renderer :last-error) (:: 'Optional 'String)
                    (:some render-error)
                      div
                        {} $ :style $ {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff1ec) (:border "|1px solid #f0c4b4") (:font-size 12) (:line-height |1.5) (:color |#a23f1a) (:margin-top 8)
                        <> $ str "|Validation error: " render-error
                    (:none) nil
                  match
                    optionally $ assert-type storage-error $ :: 'Optional 'String
                    (:some current-storage-error)
                      div
                        {} $ :style $ {} (:padding "|8px 10px") (:border-radius 12) (:background-color |#fff7e9) (:border "|1px solid #e8c48f") (:font-size 12) (:line-height |1.5) (:color |#8a541d) (:margin-top 8)
                        <> $ str "|Storage error: " current-storage-error
                    (:none) nil
                  if
                    > (count channels) 1
                    div
                      {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 6) (:padding 10) (:border-radius 12) (:background-color |#fbfbf8) (:border "|1px solid #d7d7cf") (:margin-top 8)
                      div
                        {} $ :style $ {} (:font-size 12) (:font-weight |600) (:color |#4b5563)
                        <> |Channels
                      list->
                        {} $ :style $ {} (:display |flex) (:gap 6) (:flex-wrap |wrap)
                        -> channels .to-list $ map-indexed $ fn (idx channel)
                          [] idx $ button $ {} (:class-name css/button) (:inner-text channel)
                            :style $ {} (:padding "|5px 8px") (:font-size 11)
                              :background-color $ if (= channel selected-channel) |#dce3ea |#ffffff
                              :border $ if (= channel selected-channel) "|1px solid #8a8f98" "|1px solid #d7d7cf"
                            :on-click $ fn (e d!)
                              d! $ :: :select-channel channel
                  div
                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 10) (:padding 12) (:border-radius 16) (:background-color |#fbfbf8) (:border "|1px solid #d7d7cf") (:min-height |420px) (:margin-top 8)
                    div
                      {} $ :style $ {} (:font-size 13) (:font-weight |600) (:color |#4b5563)
                      <> |Preview
                    if (nil? selected-channel)
                      div
                        {} $ :style $ {} (:padding 20) (:border-radius 14) (:border "|1px dashed #d7d7cf") (:background-color |#f5f5f1) (:font-size 13) (:line-height |1.6) (:color |#6b7280)
                        if
                          > (count channels) 1
                          <> "|Select a channel to start receiving layouts."
                          <> "|Waiting for a relay channel. Open this page with ?channel=<name>."
                      match
                        optionally $ assert-type (&map:get renderer :layout) (:: 'Optional 'app.comp.container/LayoutNode)
                        (:some layout) (comp-layout-node layout)
                        (:none)
                          div
                            {} $ :style $ {} (:padding 20) (:border-radius 14) (:border "|1px dashed #d7d7cf") (:background-color |#f5f5f1) (:font-size 13) (:line-height |1.6) (:color |#6b7280)
                            <> "|Waiting for validated payloads."
                  .render drawer-plugin
                  .render help-alert
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'comp-layout-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-layout-node (node)
            match node
              (:column children)
                list->
                  {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 12) (:align-items |stretch)
                  -> children .to-list $ map-indexed $ fn (idx child)
                    [] idx $ comp-layout-node child
              (:row children)
                list->
                  {} $ :style $ {} (:display |flex) (:flex-direction |row) (:gap 12) (:flex-wrap |wrap) (:align-items |center)
                  -> children .to-list $ map-indexed $ fn (idx child)
                    [] idx $ comp-layout-node child
              (:card title children)
                div
                  {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 12) (:padding 16) (:border "|1px solid #e4d4c6") (:border-radius 16) (:background-color |#fffdf9)
                  match title
                    (:some title-text)
                      div
                        {} $ :style $ {} (:font-size 18) (:font-weight |600) (:color |#7e4f2c)
                        <> title-text
                    (:none) nil
                  list->
                    {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 10)
                    -> children .to-list $ map-indexed $ fn (idx child)
                      [] idx $ comp-layout-node child
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
                  :value $ or value |
                  :placeholder $ or placeholder $ or name |Input
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
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'app.comp.container/LayoutNode
            :features $ #{} :js-ffi
        'comp-markdown-block $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-markdown-block (text)
            let
                lines $ split-lines text
              list->
                {} $ :style $ {} (:display |flex) (:flex-direction |column) (:gap 8)
                -> lines .to-list $ map-indexed $ fn (idx line)
                  [] idx $ cond
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
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'String
            :features $ #{} :js-ffi
        'comp-math-block $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-math-block (expr display)
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
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] (:: 'List 'Dynamic) 'String
            :features $ #{} :js-ffi
        'comp-mermaid-block $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-mermaid-block (text)
            let
                payload $ build-mermaid-render-payload text
                svg-str $ if (:empty? payload) nil $ match
                  get @*rendered-svgs $ :source payload
                  (:none) nil
                  (:some result)
                    match result
                      (:ready svg) svg
                      (:rendering) nil
                      (:failed) nil
              [] (effect-mermaid text)
                div
                  {} (:class-name |mermaid-host)
                    :style $ {} (:display |flex) (:flex-direction |column) (:gap 10) (:padding 16) (:border-radius 16) (:border "|1px solid #d9cabf") (:background-color |#fffdf9)
                  div
                    {} $ :style $ {} (:font-size 13) (:font-weight |700) (:letter-spacing |1px) (:text-transform |uppercase) (:color |#8b6244)
                    <> |Mermaid
                  div $ {} (:class-name |mermaid-output)
                    :style $ {} (:min-height |120px) (:padding 12) (:border-radius 12) (:background-color |#fff) (:overflow |auto) (:border "|1px solid #eadccf") (:color |#6f5743) (:font-size 13) (:line-height |1.6) (:white-space |pre-wrap)
                    :innerHTML $ if (nil? svg-str) "|Rendering Mermaid diagram..." svg-str
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'String
            :features $ #{} :js-ffi
        'dispose-echarts-on! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispose-echarts-on! (el)
            let
                existing $ unsafe-coerce (echarts-lib/getInstanceByDom el) (:: 'JsNullish 'app.comp.container/EChartHost)
              if (js-present? existing)
                let
                    chart $ unsafe-coerce existing EChartHost
                  chart .dispose!
                , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/DomElementHost
            :features $ #{} :js-ffi
        'effect-echarts $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-echarts (option) (action el at?)
            let
                target $ unsafe-coerce el 'js-ffi.browser/DomElementHost
              case-default action &unit
                :mount $ render-echarts-on! target option
                :update $ render-echarts-on! target option
                :unmount $ dispose-echarts-on! target
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Effect)
            :args $ [] $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'effect-mathml $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-mathml (expr display) (action el at?)
            let
                target $ unsafe-coerce el MathElementHost
              case-default action &unit
                :mount $ render-mathml-on target expr $ assert-type display 'String
                :update $ render-mathml-on target expr $ assert-type display 'String
                :unmount $ do (js-set target :inner-html |) &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Effect)
            :args $ [] (:: 'List 'Dynamic) 'String
            :features $ #{} :js-ffi
        'effect-mermaid $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-mermaid (text) (action el at?)
            let
                payload $ build-mermaid-render-payload text
                target $ unsafe-coerce el 'js-ffi.browser/DomElementHost
              case-default action &unit
                :mount $ if (:empty? payload) &unit $ render-mermaid-on target payload
                :update $ if (:empty? payload) &unit $ render-mermaid-on target payload
                :unmount &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Effect)
            :args $ [] 'String
            :features $ #{} :js-ffi
        'effect-page-title $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-page-title (selected-channel) (action el at?)
            let
                next-title $ page-title-text selected-channel
              case-default action &unit
                :mount $ browser/document-title! next-title
                :update $ browser/document-title! next-title
                :unmount $ browser/document-title! $ page-title-text (Option :none)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Effect)
            :args $ [] $ :: 'Option 'String
            :features $ #{} :js-ffi
        'ensure-mermaid! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn ensure-mermaid! ()
            if (not @*mermaid-ready)
              let
                  api $ unsafe-coerce mermaid-lib MermaidHost
                api .initialize! $ js-object (:startOnLoad false) (:securityLevel |loose) (:theme |neutral)
                reset! *mermaid-ready true
                , &unit
              , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'math-display-value $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn math-display-value (display)
            if (= display |block) |block |inline
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ [] 'Dynamic
        'mathml-namespace $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def mathml-namespace |http://www.w3.org/1998/Math/MathML
          :examples $ []
          :schema $ :: 'Dynamic
        'page-title-text $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn page-title-text (selected-channel)
            str |EDN-Renderer/ $ .unwrap-or selected-channel |waiting
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ [] $ :: 'Option 'String
        'parse-layout-children $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-layout-children (children path)
            if
              not $ list? children
              raise $ str path "| field :children should be a list"
              map
                assert-type children $ :: 'List 'Dynamic
                fn (child)
                  hint-fn $ {}
                    :args $ [] 'Dynamic
                    :return 'app.comp.container/LayoutNode
                  parse-layout-node child $ str path |.children
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic 'String
            :return $ :: 'List 'app.comp.container/LayoutNode
        'parse-layout-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-layout-node (node path)
            if
              not $ map? node
              raise $ str path "| expected a map node"
              let
                  node-type $ &map:get node :type
                  children $ or (&map:get node :children) ([])
                  series $ or (&map:get node :series) ([])
                if
                  not $ string? node-type
                  raise $ str path "| is missing string field :type"
                  case-default node-type
                    raise $ str path "| does not support node type " node-type
                    |column $ %:: LayoutNode :column $ parse-layout-children children path
                    |row $ %:: LayoutNode :row $ parse-layout-children children path
                    |card $ %:: LayoutNode :card
                      optionally $ assert-type (&map:get node :text) (:: 'Optional 'String)
                      parse-layout-children children path
                    |text $ if
                      and
                        string? $ &map:get node :text
                        >
                          count $ assert-type (&map:get node :text) 'String
                          , 0
                      %:: LayoutNode :text $ assert-type (&map:get node :text) 'String
                      raise $ str path "| text node requires non-empty :text"
                    |badge $ if
                      and
                        string? $ &map:get node :text
                        >
                          count $ assert-type (&map:get node :text) 'String
                          , 0
                      %:: LayoutNode :badge $ assert-type (&map:get node :text) 'String
                      raise $ str path "| badge node requires non-empty :text"
                    |divider $ %:: LayoutNode :divider
                    |button $ if
                      and
                        string? $ &map:get node :text
                        >
                          count $ assert-type (&map:get node :text) 'String
                          , 0
                      %:: LayoutNode :button $ assert-type (&map:get node :text) 'String
                      raise $ str path "| button node requires non-empty :text"
                    |input $ if
                      or
                        some? $ &map:get node :name
                        some? $ &map:get node :placeholder
                      %:: LayoutNode :input (&map:get node :name) (&map:get node :placeholder) (&map:get node :text)
                      raise $ str path "| input node requires :name or :placeholder"
                    |markdown $ if
                      and
                        string? $ &map:get node :text
                        >
                          count $ assert-type (&map:get node :text) 'String
                          , 0
                      %:: LayoutNode :markdown $ assert-type (&map:get node :text) 'String
                      raise $ str path "| markdown node requires non-empty :text"
                    |mermaid $ if
                      and
                        string? $ &map:get node :text
                        >
                          count $ assert-type (&map:get node :text) 'String
                          , 0
                      %:: LayoutNode :mermaid $ assert-type (&map:get node :text) 'String
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
                              string? $ &map:get item :label
                              number? $ &map:get item :value
                            , true $ raise $ str path "| chart series item requires string :label and number :value"
                      %:: LayoutNode :chart
                        or (&map:get node :kind) |bar
                        or (&map:get node :title) |
                        , series
                    |math $ do
                      validate-mathml-expr (&map:get node :expr) (str path |.expr)
                      %:: LayoutNode :math
                        assert-type (&map:get node :expr) (:: 'List 'Dynamic)
                        math-display-value $ &map:get node :display
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.comp.container/LayoutNode)
            :args $ [] 'Dynamic 'String
        'render-echarts-on! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-echarts-on! (el option)
            let
                existing $ unsafe-coerce (echarts-lib/getInstanceByDom el) (:: 'JsNullish 'app.comp.container/EChartHost)
                chart $ if (js-present? existing) (unsafe-coerce existing EChartHost)
                  unsafe-coerce (echarts-lib/init el) EChartHost
                plain-option $ unsafe-coerce (to-js-data option) JsObject
              chart .set-option! plain-option true
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/DomElementHost $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'render-mathml-on $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-mathml-on (el expr display)
            let
                root $ build-mathml-root expr display
              js-set el :inner-html |
              el .append-child! $ unsafe-coerce root JsObject
              , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'app.comp.container/MathElementHost (:: 'List 'Dynamic) 'String
            :features $ #{} :js-ffi
        'render-mermaid-on $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-mermaid-on (el payload)
            hint-fn $ {} (:async true)
              :args $ [] 'js-ffi.browser/DomElementHost 'app.comp.container/MermaidPayload
              :return 'Unit
              :features $ #{} :js-ffi
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
                            api $ unsafe-coerce mermaid-lib MermaidHost
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
                          hint-fn $ {}
                            :args $ [] 'Dynamic
                            :return 'Unit
                          reset! *rendered-svgs $ assoc @*rendered-svgs source $ MermaidCache :failed
                          host/console-error! $ str "|[mermaid] render failed: " error
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/DomElementHost 'app.comp.container/MermaidPayload
            :features $ #{} :js-ffi
        'validate-layout $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn validate-layout (layout) (parse-layout-node layout |root)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.comp.container/LayoutNode)
            :args $ [] 'Dynamic
        'validate-layout-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn validate-layout-node (node path) (parse-layout-node node path)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.comp.container/LayoutNode)
            :args $ [] 'Dynamic 'String
        'validate-mathml-child $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn validate-mathml-child (child path)
            if
              or (string? child) (number? child)
              , child $ if (list? child) (validate-mathml-expr child path)
                raise $ str path "| invalid MathML child, expected string, number, or list"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'String
        'validate-mathml-expr $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn validate-mathml-expr (expr path)
            if
              not $ list? expr
              raise $ str path "| math node requires list field :expr"
              let
                  items $ assert-type expr $ :: 'List 'Dynamic
                if (empty? items)
                  raise $ str path "| math expression should not be empty"
                  let
                      tag-name $ .unwrap $ first items
                    if
                      not $ string? tag-name
                      raise $ str path "| math expression requires string tag name"
                      do
                        foldl (rest items) &unit $ fn (acc child)
                          hint-fn $ {}
                            :args $ [] 'Unit 'Dynamic
                            :return 'Unit
                          validate-mathml-child child $ str path |/ tag-name
                          , &unit
                        , items
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic 'String
            :return $ :: 'List 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require (respo-ui.css :as css)
            respo.css :refer $ defstyle
            respo.core :refer $ defcomp defeffect <> >> div button textarea span input list->
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            app.config :refer $ dev?
            |echarts :as echarts-lib
            |mermaid :default mermaid-lib
            respo-alerts.core :refer $ use-alert use-drawer
            js-ffi.browser :as browser
            js-ffi.shared :as host
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
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'Map 'Tag 'Dynamic
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
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'Map 'Tag 'Dynamic
        'build-skill-text $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-skill-text (topics)
            let
                sections $ select-skill-sections topics
              foldl sections skill-overview $ fn (acc item)
                hint-fn $ {}
                  :args $ [] 'String $ :: 'Map 'Tag 'String
                  :return 'String
                str acc "|\n\n## "
                  .unwrap $ get item :title
                  , "|\n\n" $ .unwrap $ get item :text
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ [] 'Dynamic
        'build-status-payload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-status-payload (relay renderer)
            {} (:status :ok) (:kind :status) (:renderer |edn-renderer)
              :title $ current-page-title
              :page_url $ current-page-url
              :commands relay-commands
              :channel $ &map:get relay :selected-channel
              :channels $ or (&map:get relay :channels) ([])
              :layout_id $ &map:get renderer :layout-id
              :last_request $ &map:get renderer :last-request
              :layout_ready? $ some? $ &map:get renderer :layout-dsl
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'Map 'Tag 'Dynamic)
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
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
          :schema $ :: 'List $ :: 'Map 'Tag 'Dynamic
        'current-page-title $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-page-title () (browser/document-title)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ []
            :features $ #{} :js-ffi
        'current-page-url $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-page-url () (browser/location-href)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ []
            :features $ #{} :js-ffi
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
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ []
            :features $ #{} :js-ffi
        'current-url-channel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-url-channel () (current-url-param |channel)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ []
            :features $ #{} :js-ffi
            :return $ :: 'Option 'String
        'current-url-param $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn current-url-param (key)
            let
                params $ shared/search-params-create $ :search (browser/location-snapshot)
              match (shared/search-params-get params key)
                (:some value)
                  if (empty? value) (%none) (%some value)
                (:none) (%none)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'String
            :features $ #{} :js-ffi
            :return $ :: 'Option 'String
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ .unwrap-or (get-env |mode) |release
          :examples $ []
          :schema $ :: 'Bool
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
          :schema $ :: 'List $ :: 'Map 'Tag 'String
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
          :schema $ :: 'List $ :: 'Map 'Tag 'String
        'relay-commands $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def relay-commands ([] |send |help |skill |status |open)
          :examples $ []
          :schema $ :: 'List 'String
        'renderer-help-overview $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def renderer-help-overview "|默认 `edn-relay help --channel <name>` 只返回总览；需要细节时再追加 topic，例如 `components`、`math`、`protocol`、`storage`、`editing`、`examples`、`layout`、`snapshot`、`layout-patch-demo`、`math-fraction-demo`，避免一次返回全部组件配置和案例。"
          :examples $ []
          :schema $ :: 'String
        'select-component-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-component-docs (topics)
            let
                normalized-topics $ if (list? topics)
                  assert-type topics $ :: 'List 'Dynamic
                  []
              if (includes? normalized-topics |components) component-docs $ filter component-docs $ fn (item)
                hint-fn $ {}
                  :args $ [] $ :: 'Map 'Tag 'Dynamic
                  :return 'Bool
                includes? normalized-topics $ .unwrap $ get item :name
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'List $ :: 'Map 'Tag 'Dynamic
        'select-example-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-example-docs (topics)
            let
                normalized-topics $ if (list? topics)
                  assert-type topics $ :: 'List 'Dynamic
                  []
              if (includes? normalized-topics |examples) example-docs $ filter example-docs $ fn (item)
                hint-fn $ {}
                  :args $ [] $ :: 'Map 'Tag 'String
                  :return 'Bool
                includes? normalized-topics $ .unwrap $ get item :name
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'List $ :: 'Map 'Tag 'String
        'select-protocol-docs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-protocol-docs (topics)
            let
                normalized-topics $ if (list? topics)
                  assert-type topics $ :: 'List 'Dynamic
                  []
              if (includes? normalized-topics |protocol) protocol-docs $ filter protocol-docs $ fn (item)
                hint-fn $ {}
                  :args $ [] $ :: 'Map 'Tag 'String
                  :return 'Bool
                includes? normalized-topics $ .unwrap $ get item :name
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'List $ :: 'Map 'Tag 'String
        'select-skill-sections $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-skill-sections (topics)
            let
                normalized-topics $ if (list? topics)
                  assert-type topics $ :: 'List 'Dynamic
                  []
              if (includes? normalized-topics |all) skill-sections $ filter skill-sections $ fn (item)
                hint-fn $ {}
                  :args $ [] $ :: 'Map 'Tag 'String
                  :return 'Bool
                includes? normalized-topics $ .unwrap $ get item :name
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'List $ :: 'Map 'Tag 'String
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            {} (:storage-key |workflow) (:relay-url |ws://127.0.0.1:9100)
          :examples $ []
          :schema $ :: 'Map 'Tag 'String
        'skill-overview $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def skill-overview "|使用 `edn-relay skill --channel <name>` 获取高层工作流；默认只返回总览。需要细节时追加 topic，例如 `workflow`、`help`、`storage`、`layout`、`math`、`validation`；如果确实要整份文档，再用 `full`。"
          :examples $ []
          :schema $ :: 'String
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
          :schema $ :: 'List $ :: 'Map 'Tag 'String
        'skill-text $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def skill-text (slurp-file |SKILL.md)
          :examples $ []
          :schema $ :: 'String
        'slurp-file $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defmacro slurp-file (file-path)
            read-file $ assert-type file-path 'String
          :examples $ []
          :schema $ :: 'Macro $ {}
            :capabilities $ #{} :fs-read
            :expansion $ :: 'Expr 'String
            :required $ [] 'Syntax
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
          :require (js-ffi.browser :as browser) (js-ffi.shared :as shared)
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *reel
            -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
          :examples $ []
          :schema $ :: 'Dynamic
        '*ws $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *ws (Option :none)
          :examples $ []
          :schema $ :: 'Ref $ :: 'Option 'js-ffi.browser/WebSocketHost
        'RendererRequest $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum RendererRequest
            :help $ :: 'List 'String
            :skill $ :: 'List 'String
            :status
            :snapshot $ :: 'List 'Number
            :layout $ :: 'List 'Number
            :node $ :: 'List 'Number
            :patch (:: 'List 'Number) 'Dynamic
            :replace (:: 'List 'Number) 'Dynamic
            :invalid
          :examples $ []
          :schema $ :: 'Enum
        'build-saved-report-entry $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn build-saved-report-entry (relay renderer)
            let
                channel $ &map:get relay :selected-channel
                layout-dsl $ &map:get renderer :layout-dsl
                layout-id $ &map:get renderer :layout-id
                request-id $ &map:get renderer :last-request
                saved-at $ :iso $ host/date-now-snapshot
                layout-source $ &map:get renderer :layout-source
                source $ if (some? layout-source) layout-source $ format-cirru-edn layout-dsl
              {} (:kind :saved-report) (:channel channel)
                :title $ str (or channel |report) "| / " $ or layout-id |snapshot
                :layout_id layout-id
                :request_id request-id
                :saved_at saved-at
                :layout layout-dsl
                :source source
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'Map 'Tag 'Dynamic)
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when
              and config/dev? $ not= op :states
              js/console.log |Dispatch: op
            let
                next-reel $ reel-updater updater @*reel op
              reset! *reel next-reel
              match @*ws
                (:some socket)
                  match op
                    (:select-channel _) (sync-selected-channel! socket)
                    (:request-storage-list) (request-storage-list! socket)
                    (:save-current-report) (request-storage-save! socket)
                    (:load-stored-report name) (request-storage-load! socket name)
                    _ &unit
                (:none) &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'ensure-relay! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn ensure-relay! ()
            do
              when (.none? @*ws)
                dispatch! $ :: :relay-status |connecting nil
                let
                    relay-url $ config/current-relay-url
                    ws $ browser/web-socket-create relay-url
                    client-id $ str |renderer- $ :iso (host/date-now-snapshot)
                  reset! *ws $ Option :some ws
                  browser/web-socket-on-open! ws $ fn (event)
                    dispatch! $ :: :relay-connected client-id $ []
                    sync-selected-channel! ws
                  browser/web-socket-on-message! ws $ fn (text) (handle-relay-message! ws text) &unit
                  browser/web-socket-on-error! ws $ fn (event)
                    dispatch! $ :: :relay-status |error "|Relay websocket error"
                  browser/web-socket-on-close! ws $ fn (event)
                    reset! *ws $ Option :none
                    dispatch! $ :: :relay-status |closed "|Relay connection closed, retrying..."
                    browser/set-timeout! ensure-relay! 2000
                    , &unit
              , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'handle-channel-state! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-channel-state! (ws client-id channels)
            do
              let
                  normalized $ if (list? channels)
                    assert-type channels $ :: 'List 'String
                    []
                match client-id
                  (:some id)
                    dispatch! $ :: :relay-connected id normalized
                  (:none)
                    dispatch! $ :: :relay-channels normalized
                when
                  and
                    .none? $ selected-relay-channel
                    = 1 $ count normalized
                  dispatch! $ :: :select-channel $ .unwrap (first normalized)
              , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost (:: 'Option 'String) 'Dynamic
            :features $ #{} :js-ffi
        'handle-genui-event! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-genui-event! (ws frame)
            let
                request-id $ assert-type (&map:get frame :id) 'String
                payload $ &map:get frame :payload
                source $ format-cirru-edn payload
                layout-id $ str |layout- request-id
              try
                let
                    layout $ -> payload validate-layout
                    ack-payload $ {} (:status :ok) (:layout_id layout-id)
                  do
                    dispatch! $ :: :genui-applied request-id layout-id layout payload source
                    send-genui-ack! ws request-id true ack-payload $ optionally $ assert-type nil (:: 'Optional 'String)
                fn (error)
                  let
                      message $ :message $ host/normalize-error error
                    do
                      dispatch! $ :: :genui-failed request-id message source
                      host/console-warn! $ str "|[renderer] validation failed: " message
                      send-genui-ack! ws request-id false nil $ optionally $ assert-type message (:: 'Optional 'String)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'handle-relay-message! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-relay-message! (ws raw)
            do
              let
                  frame $ assert-type (parse-cirru-edn raw) (:: 'Map 'Tag 'Dynamic)
                  kind $ .unwrap-or
                    protocol-name $ &map:get frame :kind
                    , nil
                  payload $ &map:get frame :payload
                  request $ parse-renderer-request payload
                  selected $ selected-relay-channel
                  pending-storage $ optionally $ assert-type
                    .unwrap-or
                      get-in @*reel $ [] :store :renderer :storage-pending
                      , nil
                    :: 'Optional $ :: 'Map 'Tag 'Dynamic
                  summary $ if (= kind |hello-ok) "|Relay connected" $ if (= kind |channel-state) "|Channel list updated"
                    if (= kind |warning)
                      or (&map:get frame :error) "|Relay warning"
                      if (= kind |error)
                        or (&map:get frame :error) "|Relay error"
                        if
                          and (= kind |ack) (.some? pending-storage)
                            = (&map:get frame :id)
                              &map:get (.unwrap pending-storage) :request-id
                          str "|Storage " $ or
                            &map:get (.unwrap pending-storage) :op
                            , |request
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
                do
                  dispatch! $ :: :record-relay-message $ {} (:kind kind)
                    :channel $ &map:get frame :channel
                    :request-id $ &map:get frame :id
                    :matched? $ if (= kind |event)
                      and (.some? selected)
                        = (&map:get frame :channel) (.unwrap selected)
                      , true
                    :summary summary
                    :raw raw
                  if (= kind |hello-ok)
                    handle-channel-state! ws
                      optionally $ assert-type (&map:get frame :client_id) (:: 'Optional 'String)
                      &map:get frame :channels
                    if (= kind |channel-state)
                      handle-channel-state! ws
                        optionally $ assert-type nil $ :: 'Optional 'String
                        &map:get frame :channels
                      if (= kind |event)
                        if
                          and (.some? selected)
                            = (&map:get frame :channel) (.unwrap selected)
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
                          do |ignored
                        if
                          and (= kind |ack) (.some? pending-storage)
                            = (&map:get frame :id)
                              &map:get (.unwrap pending-storage) :request-id
                          handle-storage-ack! frame
                          if (= kind |warning)
                            host/console-warn! $ assert-type
                              or (&map:get frame :error) "|Relay warning"
                              , 'String
                            if (= kind |error)
                              dispatch! $ :: :relay-status |error $ or (&map:get frame :error) "|Relay error"
                              do |ignored
              , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost 'String
            :features $ #{} :js-ffi
        'handle-renderer-event! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-renderer-event! (ws frame)
            let
                request-id $ assert-type (&map:get frame :id) 'String
                payload $ &map:get frame :payload
                request $ parse-renderer-request payload
                relay $ assert-type
                  .unwrap $ get-in @*reel $ [] :store :relay
                  :: 'Map 'Tag 'Dynamic
                renderer $ assert-type
                  .unwrap $ get-in @*reel $ [] :store :renderer
                  :: 'Map 'Tag 'Dynamic
              do
                host/console-log! $ str "|[renderer] request " payload
                try
                  match request
                    (:help topics)
                      let
                          response-payload $ config/build-help-payload topics
                        send-genui-ack! ws request-id true response-payload $ Option :none
                    (:skill topics)
                      send-genui-ack! ws request-id true (config/build-skill-payload topics) (Option :none)
                    (:status)
                      send-genui-ack! ws request-id true (config/build-status-payload relay renderer) (Option :none)
                    (:snapshot path)
                      if-let
                        layout-dsl $ optionally $ assert-type (&map:get renderer :layout-dsl)
                          :: 'Optional $ :: 'Map 'Tag 'Dynamic
                        let
                            target-node $ layout-node-at-path layout-dsl path
                            response-payload $ {} (:status :ok) (:kind :snapshot)
                              :path $ layout-path-display path
                              :tree $ summarize-layout-node target-node path
                          send-genui-ack! ws request-id true response-payload $ Option :none
                        send-genui-ack! ws request-id false nil $ Option :some "|No layout loaded in renderer"
                    (:layout path)
                      if-let
                        layout-dsl $ optionally $ assert-type (&map:get renderer :layout-dsl)
                          :: 'Optional $ :: 'Map 'Tag 'Dynamic
                        let
                            target-node $ layout-node-at-path layout-dsl path
                            response-payload $ {} (:status :ok) (:kind :layout)
                              :layout_id $ &map:get renderer :layout-id
                              :path $ layout-path-display path
                              :summary $ summarize-layout-node target-node path
                          send-genui-ack! ws request-id true response-payload $ Option :none
                        send-genui-ack! ws request-id false nil $ Option :some "|No layout loaded in renderer"
                    (:node path)
                      if-let
                        layout-dsl $ optionally $ assert-type (&map:get renderer :layout-dsl)
                          :: 'Optional $ :: 'Map 'Tag 'Dynamic
                        let
                            target-node $ layout-node-at-path layout-dsl path
                            response-payload $ {} (:status :ok) (:kind :node)
                              :layout_id $ &map:get renderer :layout-id
                              :path $ layout-path-display path
                              :dsl target-node
                              :source $ format-cirru-edn target-node
                              :summary $ summarize-layout-node target-node path
                          send-genui-ack! ws request-id true response-payload $ Option :none
                        send-genui-ack! ws request-id false nil $ Option :some "|No layout loaded in renderer"
                    (:patch path changes)
                      if-let
                        layout-dsl $ optionally $ assert-type (&map:get renderer :layout-dsl)
                          :: 'Optional $ :: 'Map 'Tag 'Dynamic
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
                            send-genui-ack! ws request-id true response-payload $ Option :none
                        send-genui-ack! ws request-id false nil $ Option :some "|No layout loaded in renderer"
                    (:replace path next-node)
                      if-let
                        layout-dsl $ optionally $ assert-type (&map:get renderer :layout-dsl)
                          :: 'Optional $ :: 'Map 'Tag 'Dynamic
                        let
                            next-dsl $ replace-layout-node-at-path layout-dsl path $ assert-type next-node (:: 'Map 'Tag 'Dynamic)
                            next-layout $ validate-layout next-dsl
                            next-source $ format-cirru-edn next-dsl
                            next-layout-id $ str |layout- request-id
                            response-payload $ {} (:status :ok) (:kind :replace) (:layout_id next-layout-id)
                              :path $ layout-path-display path
                              :dsl $ layout-node-at-path next-dsl path
                              :summary $ summarize-layout-node (layout-node-at-path next-dsl path) path
                          do
                            dispatch! $ :: :layout-mutated request-id next-layout-id next-layout next-dsl next-source
                            send-genui-ack! ws request-id true response-payload $ Option :none
                        send-genui-ack! ws request-id false nil $ Option :some "|No layout loaded in renderer"
                    (:invalid)
                      send-genui-ack! ws request-id false nil $ Option :some "|Unsupported renderer request"
                  fn (error)
                    let
                        message $ :message $ host/normalize-error error
                      do
                        host/console-warn! $ str "|[renderer] request failed: " message
                        send-genui-ack! ws request-id false nil $ Option :some message
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'handle-storage-ack! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-storage-ack! (frame)
            do
              let
                  request-id $ assert-type (&map:get frame :id) 'String
                  pending $ optionally $ assert-type
                    .unwrap-or
                      get-in @*reel $ [] :store :renderer :storage-pending
                      , nil
                    :: 'Optional $ :: 'Map 'Tag 'Dynamic
                when
                  and (.some? pending)
                    = request-id $ &map:get (.unwrap pending) :request-id
                  if (&map:get frame :ok)
                    try
                      let
                          payload $ assert-type (&map:get frame :payload) (:: 'Map 'Tag 'Dynamic)
                          kind $ .unwrap-or
                            protocol-name $ &map:get payload :kind
                            , nil
                        if (= kind |storage-list)
                          dispatch! $ :: :storage-listed request-id $ if
                            list? $ &map:get payload :entries
                            &map:get payload :entries
                            []
                          if (= kind |storage-save)
                            do
                              dispatch! $ :: :storage-saved request-id payload
                              match @*ws
                                (:some socket) (request-storage-list! socket)
                                (:none) &unit
                            if (= kind |storage-load)
                              let
                                  entry $ assert-type (&map:get payload :entry) (:: 'Map 'Tag 'Dynamic)
                                  layout-dsl $ &map:get entry :layout
                                  source $ or (&map:get payload :source) (&map:get entry :source) (format-cirru-edn layout-dsl)
                                  layout-id $ or (&map:get entry :layout_id)
                                    str |saved- $ &map:get payload :name
                                  layout $ validate-layout layout-dsl
                                dispatch! $ :: :storage-loaded request-id payload layout-id layout layout-dsl source
                              dispatch! $ :: :storage-failed request-id "|Unsupported storage ack payload"
                      fn (error)
                        let
                            message $ :message $ host/normalize-error error
                          dispatch! $ :: :storage-failed request-id message
                    dispatch! $ :: :storage-failed request-id $ or (&map:get frame :error) "|Storage request failed"
              , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'internal-storage-channel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def internal-storage-channel |__relay_store__
          :examples $ []
          :schema $ :: 'Dynamic
        'layout-node-at-path $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn layout-node-at-path (node path)
            if (empty? path) node $ let
                children $ or (&map:get node :children) ([])
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
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'List 'Number)
            :return $ :: 'Map 'Tag 'Dynamic
        'layout-path-display $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn layout-path-display (path)
            if (empty? path) |root $ layout-path-display-iter path |
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ [] $ :: 'List 'Number
        'layout-path-display-iter $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn layout-path-display-iter (path acc)
            if (empty? path) acc $ let
                step $ str $ .unwrap (first path)
              recur (rest path)
                if (= acc |) step $ str acc |. step
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ [] (:: 'List 'Number) 'String
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            if config/dev? $ load-console-formatter!
            render-app!
            add-watch *reel :changes $ fn (reel prev) (render-app!)
            listen-devtools! |k dispatch!
            browser/add-event-listener! |beforeunload $ fn (event) (persist-storage!)
            browser/add-event-listener! |visibilitychange $ fn (event)
              match (browser/visibility-state)
                (:hidden) (persist-storage!)
                _ &unit
            browser/set-interval! persist-storage! 60000
            match
              browser/storage-get $ .unwrap $ get config/site :storage-key
              (:some raw)
                dispatch! $ :: :hydrate-storage $ parse-cirru-edn raw
              (:none) &unit
            match (config/current-url-channel)
              (:some url-channel)
                dispatch! $ :: :select-channel url-channel
              (:none) &unit
            ensure-relay!
            println "|App started."
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'merge-layout-node-at-path $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn merge-layout-node-at-path (node path changes)
            if
              not $ map? changes
              raise "|Patch request expects map field :changes"
              replace-layout-node-at-path node path $ merge (layout-node-at-path node path)
                assert-type changes $ :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'List 'Number) 'Dynamic
            :return $ :: 'Map 'Tag 'Dynamic
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def mount-target
            .unwrap $ browser/query-selector |.app
          :examples $ []
          :schema $ :: 'js-ffi.browser/DomElementHost
        'normalize-layout-path $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-layout-path (path)
            if (nil? path)
              Option :some $ []
              if (number? path)
                match (parse-layout-path-segment path)
                  (:some segment)
                    Option :some $ [] segment
                  (:none) (Option :none)
                if (list? path)
                  normalize-layout-path-items $ assert-type path $ :: 'List 'Dynamic
                  if
                    or (string? path) (tag? path)
                    let
                        raw $ turn-string path
                      if
                        or (= raw |) (= raw |root)
                        Option :some $ []
                        normalize-layout-path-items $ split raw |.
                    Option :none
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'Option $ :: 'List 'Number
        'normalize-layout-path-items $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-layout-path-items (items)
            foldl items
              Option :some $ []
              fn (acc item)
                hint-fn $ {}
                  :args $ []
                    :: 'Option $ :: 'List 'Number
                    , 'Dynamic
                  :return $ :: 'Option $ :: 'List 'Number
                match acc
                  (:none) (Option :none)
                  (:some segments)
                    match (parse-layout-path-segment item)
                      (:some segment)
                        Option :some $ append segments segment
                      (:none) (Option :none)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] $ :: 'List 'Dynamic
            :return $ :: 'Option $ :: 'List 'Number
        'normalize-renderer-topics $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-renderer-topics (topics)
            if (list? topics)
              foldl
                assert-type topics $ :: 'List 'Dynamic
                []
                fn (acc item)
                  hint-fn $ {}
                    :args $ [] (:: 'List 'String) 'Dynamic
                    :return $ :: 'List 'String
                  if
                    or (string? item) (tag? item)
                    append acc $ turn-string item
                    , acc
              []
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'List 'String
        'parse-layout-path-segment $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-layout-path-segment (item)
            if (number? item)
              let
                  n $ assert-type item 'Number
                if (> n 0) (Option :some n) (Option :none)
              if
                or (string? item) (tag? item)
                let
                    text $ turn-string item
                    digits? $ foldl (split text |) true $ fn (valid? ch)
                      hint-fn $ {}
                        :args $ [] 'Bool 'String
                        :return 'Bool
                      and valid? $ includes? |0123456789 ch
                  if
                    and
                      not $ empty? text
                      , digits?
                    match (parse-float text)
                      (:ok n) (Option :some n)
                      (:err _) (Option :none)
                    Option :none
                Option :none
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'Option 'Number
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
                    RendererRequest :patch normalized changes
                    RendererRequest :invalid
                (:replace path next-node)
                  if-let
                    normalized $ normalize-layout-path path
                    RendererRequest :replace normalized next-node
                    RendererRequest :invalid
                _ $ RendererRequest :invalid
              if (map? payload)
                let
                    payload $ assert-type payload $ :: 'Map 'Tag 'Dynamic
                    op-name $ .unwrap-or
                      protocol-name $ &map:get payload :op
                      , nil
                    topics $ normalize-renderer-topics $ &map:get payload :topics
                  case-default op-name (RendererRequest :invalid)
                    |help $ RendererRequest :help topics
                    |skill $ RendererRequest :skill topics
                    |status $ RendererRequest :status
                    |snapshot $ let
                        normalized $ normalize-layout-path $ &map:get payload :path
                      if (.some? normalized)
                        RendererRequest :snapshot $ .unwrap normalized
                        RendererRequest :invalid
                    |layout $ let
                        normalized $ normalize-layout-path $ &map:get payload :path
                      if (.some? normalized)
                        RendererRequest :layout $ .unwrap normalized
                        RendererRequest :invalid
                    |node $ let
                        normalized $ normalize-layout-path $ &map:get payload :path
                      if (.some? normalized)
                        RendererRequest :node $ .unwrap normalized
                        RendererRequest :invalid
                    |patch $ let
                        normalized $ normalize-layout-path $ &map:get payload :path
                      if (.some? normalized)
                        RendererRequest :patch (.unwrap normalized) (&map:get payload :changes)
                        RendererRequest :invalid
                    |replace $ let
                        normalized $ normalize-layout-path $ &map:get payload :path
                      if (.some? normalized)
                        RendererRequest :replace (.unwrap normalized)
                          or (&map:get payload :node) (&map:get payload :dsl)
                        RendererRequest :invalid
                RendererRequest :invalid
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.main/RendererRequest)
            :args $ [] 'Dynamic
        'persist-storage! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-storage! ()
            println "|Saved at" $ :iso $ host/date-now-snapshot
            .set-item! (browser/window-local-storage)
              .unwrap $ get config/site :storage-key
              format-cirru-edn $ .unwrap $ get @*reel :store
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'pick-layout-child $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn pick-layout-child (children position)
            if (list? children)
              let
                  items $ assert-type children $ :: 'List 'Dynamic
                if
                  or (<= position 0) (empty? items)
                  Option :none
                  if (= position 1)
                    Option :some $ assert-type
                      .unwrap $ first items
                      :: 'Map 'Tag 'Dynamic
                    recur (rest items) (dec position)
              Option :none
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic 'Number
            :return $ :: 'Option $ :: 'Map 'Tag 'Dynamic
        'protocol-name $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn protocol-name (x)
            if
              or (string? x) (tag? x)
              Option :some $ turn-string x
              Option :none
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'Option 'String
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            do
              if (nil? build-errors)
                do (remove-watch *reel :changes) (clear-cache!)
                  add-watch *reel :changes $ fn (reel prev) (render-app!)
                  reset! *reel $ assert-type (refresh-reel @*reel schema/store updater) (:: 'Map 'Tag 'Dynamic)
                  ensure-relay!
                  hud! |ok~ |Ok
                hud! |error build-errors
              , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render! mount-target (comp-container @*reel) dispatch!
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'replace-layout-node-at-path $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn replace-layout-node-at-path (node path next-node)
            if (empty? path) next-node $ let
                children $ or (&map:get node :children) ([])
                step $ .unwrap $ first path
              if
                not $ list? children
                raise $ str "|Path " (layout-path-display path) "| requires a parent with :children"
                if
                  .none? $ pick-layout-child children step
                  raise $ str "|Missing layout node at path " $ layout-path-display path
                  assoc node :children $ map-indexed
                    assert-type children $ :: 'List $ :: 'Map 'Tag 'Dynamic
                    fn (idx child)
                      hint-fn $ {}
                        :args $ [] 'Number $ :: 'Map 'Tag 'Dynamic
                        :return $ :: 'Map 'Tag 'Dynamic
                      if
                        = (inc idx) step
                        replace-layout-node-at-path child (rest path) next-node
                        , child
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'List 'Number) (:: 'Map 'Tag 'Dynamic)
            :return $ :: 'Map 'Tag 'Dynamic
        'request-storage-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn request-storage-list! (ws)
            match (selected-relay-channel)
              (:some channel)
                let
                    request-id $ str |storage-list- $ host/now-ms
                  do
                    dispatch! $ :: :storage-pending request-id |list
                    send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                      :payload $ {} (:op :list) (:channel channel)
              (:none)
                dispatch! $ :: :storage-failed nil "|Select a channel before browsing saved reports"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost
            :features $ #{} :js-ffi
        'request-storage-load! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn request-storage-load! (ws name)
            match (selected-relay-channel)
              (:some channel)
                let
                    request-id $ str |storage-load- $ host/now-ms
                  do
                    dispatch! $ :: :storage-pending request-id |load
                    send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                      :payload $ {} (:op :load) (:channel channel) (:name name)
              (:none)
                dispatch! $ :: :storage-failed nil "|Select a channel before loading saved reports"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost 'String
            :features $ #{} :js-ffi
        'request-storage-save! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn request-storage-save! (ws)
            let
                relay $ assert-type
                  .unwrap $ get-in @*reel $ [] :store :relay
                  :: 'Map 'Tag 'Dynamic
                renderer $ assert-type
                  .unwrap $ get-in @*reel $ [] :store :renderer
                  :: 'Map 'Tag 'Dynamic
              if
                and
                  some? $ &map:get relay :selected-channel
                  some? $ &map:get renderer :layout-dsl
                let
                    request-id $ str |storage-save- $ host/now-ms
                    entry $ build-saved-report-entry relay renderer
                    file-name $ str
                      or (&map:get relay :selected-channel) |report
                      , |- $ or (&map:get renderer :layout-id) (&map:get renderer :last-request) |snapshot
                  do
                    dispatch! $ :: :storage-pending request-id |save
                    send-relay-frame! ws $ {} (:kind :request) (:id request-id) (:channel internal-storage-channel)
                      :payload $ {} (:op :save)
                        :channel $ &map:get relay :selected-channel
                        :name file-name
                        :entry entry
                dispatch! $ :: :storage-failed nil "|A validated layout is required before saving a report"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost
            :features $ #{} :js-ffi
        'selected-relay-channel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn selected-relay-channel ()
            optionally $ assert-type
              .unwrap-or
                get-in @*reel $ [] :store :relay :selected-channel
                , nil
              :: 'Optional 'String
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ []
            :return $ :: 'Option 'String
        'send-genui-ack! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn send-genui-ack! (ws request-id ok? payload error-message)
            send-relay-frame! ws $ {} (:kind :ack) (:id request-id) (:ok ok?) (:payload payload)
              :error $ .unwrap-or error-message nil
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost 'String 'Bool 'Dynamic $ :: 'Option 'String
            :features $ #{} :js-ffi
        'send-relay-frame! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn send-relay-frame! (ws frame)
            browser/web-socket-send! ws $ format-cirru-edn frame
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'summarize-layout-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn summarize-layout-node (node path)
            let
                node-type $ &map:get node :type
                children $ if
                  list? $ &map:get node :children
                  assert-type (&map:get node :children)
                    :: 'List $ :: 'Map 'Tag 'Dynamic
                  []
                base $ assert-type
                  {}
                    :path $ layout-path-display path
                    :type node-type
                    :child-count $ count children
                  :: 'Map 'Tag 'Dynamic
                meta $ assert-type
                  case-default node-type ({})
                    |card $ if
                      string? $ &map:get node :text
                      {} $ :title $ &map:get node :text
                      {}
                    |text $ if
                      string? $ &map:get node :text
                      {} $ :text $ .unwrap-or
                        first $ split-lines $ assert-type (&map:get node :text) 'String
                        , nil
                      {}
                    |badge $ if
                      string? $ &map:get node :text
                      {} $ :text $ &map:get node :text
                      {}
                    |button $ if
                      string? $ &map:get node :text
                      {} $ :text $ &map:get node :text
                      {}
                    |input $ {}
                      :name $ &map:get node :name
                      :placeholder $ &map:get node :placeholder
                    |markdown $ {} $ :lines
                      count $ split-lines $ assert-type
                        or (&map:get node :text) |
                        , 'String
                    |mermaid $ {} $ :lines
                      count $ split-lines $ assert-type
                        or (&map:get node :text) |
                        , 'String
                    |chart $ {}
                      :kind $ or (&map:get node :kind) |bar
                      :title $ or (&map:get node :title) |
                      :series-count $ count $ assert-type
                        or (&map:get node :series) ([])
                        :: 'List 'Dynamic
                    |math $ {}
                      :display $ or (&map:get node :display) |inline
                      :expr-tag $ .unwrap-or
                        first $ assert-type
                          or (&map:get node :expr) ([])
                          :: 'List 'Dynamic
                        , nil
                  :: 'Map 'Tag 'Dynamic
              merge base $ if
                > (count children) 0
                assoc meta :children $ map-indexed children $ fn (idx child)
                  hint-fn $ {}
                    :args $ [] 'Number $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  summarize-layout-node child $ append path $ inc idx
                , meta
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'List 'Number)
            :return $ :: 'Map 'Tag 'Dynamic
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
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.browser/WebSocketHost
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
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
            js-ffi.shared :as host
            js-ffi.browser :as browser
    'app.schema $ %{} 'FileEntry
      :defs $ {} $ 'store
        %{} 'CodeEntry (:doc |)
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
          :schema $ :: 'Dynamic
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
                    cache $ assert-type
                      or (&map:get renderer :channel-cache) ({})
                      :: 'Map 'String $ :: 'Map 'Tag 'Dynamic
                  assoc renderer :channel-cache $ assoc cache channel-name $ pick-renderer-channel-state renderer
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'Option 'String)
            :return $ :: 'Map 'Tag 'Dynamic
        'pick-renderer-channel-state $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn pick-renderer-channel-state (renderer)
            {}
              :layout $ &map:get renderer :layout
              :layout-dsl $ &map:get renderer :layout-dsl
              :layout-id $ &map:get renderer :layout-id
              :layout-source $ &map:get renderer :layout-source
              :last-request $ &map:get renderer :last-request
              :last-error $ &map:get renderer :last-error
              :storage-status $ &map:get renderer :storage-status
              :storage-error $ &map:get renderer :storage-error
              :storage-pending $ &map:get renderer :storage-pending
              :storage-entries $ &map:get renderer :storage-entries
              :selected-storage $ &map:get renderer :selected-storage
              :workspace-entry $ &map:get renderer :workspace-entry
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] $ :: 'Map 'Tag 'Dynamic
            :return $ :: 'Map 'Tag 'Dynamic
        'renderer-channel-default $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def renderer-channel-default
            {} (:layout nil) (:layout-dsl nil) (:layout-id nil) (:layout-source |) (:last-request nil) (:last-error nil) (:storage-status |idle) (:storage-error nil) (:storage-pending nil)
              :storage-entries $ []
              :selected-storage nil
              :workspace-entry nil
          :examples $ []
          :schema $ :: 'Map 'Tag 'Dynamic
        'restore-renderer-channel-state $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn restore-renderer-channel-state (renderer channel)
            let
                next-state $ let
                    cache $ assert-type
                      or (&map:get renderer :channel-cache) ({})
                      :: 'Map 'String $ :: 'Map 'Tag 'Dynamic
                    cached $ match channel
                      (:none)
                        assert-type ({}) (:: 'Map 'Tag 'Dynamic)
                      (:some channel-name)
                        .unwrap-or (get cache channel-name)
                          assert-type ({}) (:: 'Map 'Tag 'Dynamic)
                  merge renderer-channel-default cached
              -> renderer
                assoc :layout $ &map:get next-state :layout
                assoc :layout-dsl $ &map:get next-state :layout-dsl
                assoc :layout-id $ &map:get next-state :layout-id
                assoc :layout-source $ &map:get next-state :layout-source
                assoc :last-request $ &map:get next-state :last-request
                assoc :last-error $ &map:get next-state :last-error
                assoc :storage-status $ &map:get next-state :storage-status
                assoc :storage-error $ &map:get next-state :storage-error
                assoc :storage-pending $ &map:get next-state :storage-pending
                assoc :storage-entries $ &map:get next-state :storage-entries
                assoc :selected-storage $ &map:get next-state :selected-storage
                assoc :workspace-entry $ &map:get next-state :workspace-entry
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'Option 'String)
            :return $ :: 'Map 'Tag 'Dynamic
        'update-renderer $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn update-renderer (store f)
            let
                renderer $ assert-type
                  or (&map:get store :renderer) ({})
                  :: 'Map 'Tag 'Dynamic
              assoc store :renderer $ f renderer
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic)
              :: 'Fn $ {}
                :args $ [] $ :: 'Map 'Tag 'Dynamic
                :return $ :: 'Map 'Tag 'Dynamic
            :return $ :: 'Map 'Tag 'Dynamic
        'updater $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            match op
              (:states cursor s) (update-states store cursor s)
              (:hydrate-storage data)
                assert-type data $ :: 'Map 'Tag 'Dynamic
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
                    relay $ assert-type
                      or (&map:get store :relay) ({})
                      :: 'Map 'Tag 'Dynamic
                    current-channel $ optionally $ assert-type (&map:get relay :selected-channel) (:: 'Optional 'String)
                    prev-renderer $ assert-type
                      or (&map:get store :renderer) ({})
                      :: 'Map 'Tag 'Dynamic
                    cached-renderer $ cache-renderer-channel-state prev-renderer current-channel
                  -> store
                    assoc :relay $ assoc relay :selected-channel channel
                    assoc :renderer $ restore-renderer-channel-state cached-renderer $ optionally
                      assert-type channel $ :: 'Optional 'String
              (:relay-status status message)
                -> store
                  assoc-in ([] :relay :status) status
                  assoc-in ([] :relay :last-error) message
              (:record-relay-message entry)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  let
                      prev-renderer renderer
                      prev-history $ if
                        list? $ &map:get prev-renderer :history
                        &map:get prev-renderer :history
                        []
                    -> prev-renderer
                      assoc :history $ append prev-history entry
                      assoc :selected-history entry
              (:select-history entry)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  assoc renderer :selected-history entry
              (:open-history-drawer)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  assoc renderer :drawer-view |history
              (:open-library-drawer)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  assoc renderer :drawer-view |library
              (:request-storage-list) store
              (:save-current-report) store
              (:load-stored-report _) store
              (:load-workspace-report)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  let
                      prev-renderer renderer
                      entry $ &map:get prev-renderer :workspace-entry
                    match
                      optionally $ assert-type entry $ :: 'Optional (:: 'Map 'Tag 'Dynamic)
                      (:some current-entry)
                        -> prev-renderer (assoc :selected-storage current-entry)
                          assoc :layout $ &map:get current-entry :layout-data
                          assoc :layout-dsl $ &map:get current-entry :layout-dsl
                          assoc :layout-id $ &map:get current-entry :layout_id
                          assoc :layout-source $ &map:get current-entry :source
                          assoc :last-request $ &map:get current-entry :request_id
                          assoc :last-error nil
                          assoc :storage-status |workspace
                          assoc :storage-error nil
                      (:none) prev-renderer
              (:storage-pending request-id op-name)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  -> renderer
                    assoc :storage-pending $ {} (:request-id request-id) (:op op-name)
                    assoc :storage-status |working
                    assoc :storage-error nil
              (:storage-saved request-id entry)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  -> renderer (assoc :storage-pending nil) (assoc :storage-status |saved) (assoc :storage-error nil) (assoc :selected-storage entry)
              (:storage-listed request-id entries)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  -> renderer (assoc :storage-pending nil) (assoc :storage-status |ready) (assoc :storage-error nil) (assoc :storage-entries entries)
              (:storage-loaded request-id entry layout-id layout layout-dsl source)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  -> renderer (assoc :storage-pending nil) (assoc :storage-status |loaded) (assoc :storage-error nil) (assoc :selected-storage entry) (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil)
              (:storage-failed request-id message)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  -> renderer (assoc :storage-pending nil) (assoc :storage-status |error) (assoc :storage-error message)
              (:genui-applied request-id layout-id layout layout-dsl source)
                let
                    entry $ ->
                      assert-type
                        {} $ :kind :workspace-report
                        :: 'Map 'Tag 'Dynamic
                      assoc :channel $ .unwrap-or
                        get-in store $ [] :relay :selected-channel
                        , nil
                      assoc :name $ str
                        or
                          .unwrap-or
                            get-in store $ [] :relay :selected-channel
                            , nil
                          , |workspace
                        , "| / current workspace"
                      assoc :path "|Local workspace snapshot. Not saved in library."
                      assoc :layout_id layout-id
                      assoc :request_id request-id
                      assoc :layout-data layout
                      assoc :layout-dsl layout-dsl
                      assoc :source source
                  update-renderer store $ fn (renderer)
                    hint-fn $ {}
                      :args $ [] $ :: 'Map 'Tag 'Dynamic
                      :return $ :: 'Map 'Tag 'Dynamic
                    -> renderer (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil) (assoc :workspace-entry entry) (assoc :selected-storage entry) (assoc :storage-status |workspace) (assoc :storage-error nil)
              (:genui-failed request-id message source)
                update-renderer store $ fn (renderer)
                  hint-fn $ {}
                    :args $ [] $ :: 'Map 'Tag 'Dynamic
                    :return $ :: 'Map 'Tag 'Dynamic
                  -> renderer (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error message)
              (:layout-mutated request-id layout-id layout layout-dsl source)
                let
                    entry $ ->
                      assert-type
                        {} $ :kind :workspace-report
                        :: 'Map 'Tag 'Dynamic
                      assoc :channel $ .unwrap-or
                        get-in store $ [] :relay :selected-channel
                        , nil
                      assoc :name $ str
                        or
                          .unwrap-or
                            get-in store $ [] :relay :selected-channel
                            , nil
                          , |workspace
                        , "| / current workspace"
                      assoc :path "|Local workspace snapshot. Not saved in library."
                      assoc :layout_id layout-id
                      assoc :request_id request-id
                      assoc :layout-data layout
                      assoc :layout-dsl layout-dsl
                      assoc :source source
                  update-renderer store $ fn (renderer)
                    hint-fn $ {}
                      :args $ [] $ :: 'Map 'Tag 'Dynamic
                      :return $ :: 'Map 'Tag 'Dynamic
                    -> renderer (assoc :layout layout) (assoc :layout-dsl layout-dsl) (assoc :layout-id layout-id) (assoc :layout-source source) (assoc :last-request request-id) (assoc :last-error nil) (assoc :workspace-entry entry) (assoc :selected-storage entry) (assoc :storage-status |workspace) (assoc :storage-error nil)
              _ $ do (eprintln "|unknown op:" op) store
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'String 'Number
            :return $ :: 'Map 'Tag 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require $ respo.cursor :refer $ update-states
