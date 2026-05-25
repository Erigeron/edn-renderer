
{} (:about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `cr query` to inspect and `cr edit`/`cr tree` to modify. Run `cr docs agents --full` first. Manual edits must follow format and schema conventions, then run `cr edit format`.") (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |respo.calcit/ |memof/ |respo-ui.calcit/ |reel.calcit/
  :entries $ {}
  :files $ {}
    |app.comp.container $ %{} :FileEntry
      :defs $ {}
        |comp-container $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defcomp comp-container (reel)
              let
                  store $ :store reel
                  states $ :states store
                  relay $ or (:relay store) ({})
                  renderer $ or (:renderer store) ({})
                div
                  {} $ :style
                    {} (:min-height |100vh) (:padding 24) (:box-sizing |border-box) (:background-color |#f6efe6) (:color |#2b2018) (:font-family |Avenir)
                  div
                    {} $ :style
                      {} (:display |flex) (:gap 20) (:align-items |flex-start)
                    div
                      {} $ :style
                        {} (:width |320px) (:display |flex) (:flex-direction |column) (:gap 12) (:padding 18) (:border-radius 20) (:background-color |#fffaf4) (:border "|1px solid #ead8c7")
                      div
                        {} $ :style
                          {} (:font-size 28) (:font-weight |700) (:line-height |1.1)
                        <> "|EDN Renderer"
                      div
                        {} $ :style
                          {} (:font-size 13) (:line-height |1.6) (:color |#7e6650)
                        <> "|Listening on relay channel genui, validating incoming Cirru EDN layouts and rendering the accepted result."
                      div
                        {} $ :style
                          {} (:display |flex) (:flex-direction |column) (:gap 8) (:padding 12) (:border-radius 14) (:background-color |#f4e7d8)
                        div ({})
                          <> $ str "|Relay status: "
                            or (:status relay) |idle
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
                          {} (:display |flex) (:flex-direction |column) (:gap 8)
                        div ({})
                          <> $ str "|Layout id: "
                            or (:layout-id renderer) |waiting
                        if-let
                          request-id $ :last-request renderer
                          div ({})
                            <> $ str "|Request: " request-id
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
                        :style $ {} (:width |100%) (:min-height |260px) (:padding 12) (:box-sizing |border-box) (:border-radius 14) (:border "|1px solid #dcc8b6") (:background-color |#fff) (:font-family |Monaco) (:font-size 12) (:line-height |1.6) (:resize |vertical)
                      when dev? $ comp-reel (>> states :reel) reel ({})
                    div
                      {} $ :style
                        {} (:flex |1) (:display |flex) (:flex-direction |column) (:gap 16) (:padding 22) (:border-radius 24) (:background-color |#fff7ef) (:border "|1px solid #ecdccf")
                      div
                        {} $ :style
                          {} (:font-size 20) (:font-weight |600)
                        <> "|Rendered Preview"
                      if-let
                        layout $ :layout renderer
                        comp-layout-node layout
                        div
                          {} $ :style
                            {} (:padding 32) (:border-radius 18) (:border "|1px dashed #d7bca4") (:background-color |#fffbf6) (:font-size 15) (:line-height |1.7) (:color |#8b6c52)
                          <> "|Waiting for a validated genui layout from the relay."
          :examples $ []
        |comp-layout-node $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defcomp comp-layout-node (node)
              let
                  node-type $ :type node
                  children $ or (:children node) ([])
                case-default node-type
                  div
                    {} $ :style
                      {} (:padding 12) (:border "|1px solid #f08c6c") (:border-radius 12) (:background-color |#fff4ef) (:color |#9b3d15)
                    <> $ str "|Unsupported node type: " node-type
                  |column $ list->
                    {} $ :style
                      {} (:display |flex) (:flex-direction |column) (:gap 12) (:align-items |stretch)
                    -> children .to-list $ map-indexed
                      fn (idx child)
                        [] idx $ comp-layout-node child
                  |row $ list->
                    {} $ :style
                      {} (:display |flex) (:flex-direction |row) (:gap 12) (:flex-wrap |wrap) (:align-items |center)
                    -> children .to-list $ map-indexed
                      fn (idx child)
                        [] idx $ comp-layout-node child
                  |card $ div
                    {} $ :style
                      {} (:display |flex) (:flex-direction |column) (:gap 12) (:padding 16) (:border "|1px solid #e4d4c6") (:border-radius 16) (:background-color |#fffdf9)
                    if-let
                      title $ :text node
                      div
                        {} $ :style
                          {} (:font-size 18) (:font-weight |600) (:color |#7e4f2c)
                        <> title
                    list->
                      {} $ :style
                        {} (:display |flex) (:flex-direction |column) (:gap 10)
                      -> children .to-list $ map-indexed
                        fn (idx child)
                          [] idx $ comp-layout-node child
                  |text $ div
                    {} $ :style
                      {} (:font-size 16) (:line-height |1.6) (:color |#2e241c)
                    <> $ :text node
                  |badge $ div
                    {} $ :style
                      {} (:display |inline-flex) (:align-items |center) (:padding 8) (:border-radius 999) (:background-color |#f3d7ba) (:color |#7d4d27) (:font-size 12) (:font-weight |600) (:width |fit-content)
                    <> $ :text node
                  |divider $ div
                    {} $ :style
                      {} (:height 1) (:width |100%) (:background-color |#e6d4c4)
                  |button $ button
                    {} (:disabled true)
                      :inner-text $ :text node
                      :style $ {} (:padding 10) (:border "|1px solid #cf8b5d") (:background-color |#e8b488) (:color |#3e2515) (:border-radius 999) (:font-size 14) (:font-weight |600) (:cursor |not-allowed)
                  |input $ input
                    {} (:disabled true)
                      :value $ or (:text node) |
                      :placeholder $ or (:placeholder node)
                        or (:name node) |Input
                      :style $ {} (:padding 10) (:border "|1px solid #d8c8ba") (:border-radius 12) (:font-size 14) (:background-color |#fff) (:min-width |160px)
          :examples $ []
        |validate-layout $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn validate-layout (layout) (validate-layout-node layout |root) layout
          :examples $ []
        |validate-layout-node $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn validate-layout-node (node path)
              if
                not $ map? node
                raise $ str path "| expected a map node"
                let
                    node-type $ :type node
                    children $ or (:children node) ([])
                  if
                    not $ string? node-type
                    raise $ str path "| is missing string field :type"
                    case-default node-type
                      raise $ str path "| does not support node type " node-type
                      |column $ do
                        if
                          not $ list? children
                          raise $ str path "| field :children should be a list"
                        every? children $ fn (child)
                          validate-layout-node child $ str path |.children
                        , node
                      |row $ do
                        if
                          not $ list? children
                          raise $ str path "| field :children should be a list"
                        every? children $ fn (child)
                          validate-layout-node child $ str path |.children
                        , node
                      |card $ do
                        if
                          not $ list? children
                          raise $ str path "| field :children should be a list"
                        every? children $ fn (child)
                          validate-layout-node child $ str path |.children
                        , node
                      |text $ if
                        and
                          string? $ :text node
                          >
                            count $ :text node
                            , 0
                        , node
                          raise $ str path "| text node requires non-empty :text"
                      |badge $ if
                        and
                          string? $ :text node
                          >
                            count $ :text node
                            , 0
                        , node
                          raise $ str path "| badge node requires non-empty :text"
                      |divider $ do node
                      |button $ if
                        and
                          string? $ :text node
                          >
                            count $ :text node
                            , 0
                        , node
                          raise $ str path "| button node requires non-empty :text"
                      |input $ if
                        or
                          some? $ :name node
                          some? $ :placeholder node
                        , node
                          raise $ str path "| input node requires :name or :placeholder"
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns app.comp.container $ :require (respo-ui.css :as css)
            respo.css :refer $ defstyle
            respo.core :refer $ defcomp <> >> div button textarea span input list->
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            app.config :refer $ dev?
    |app.config $ %{} :FileEntry
      :defs $ {}
        |dev? $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def dev? $ = |dev (get-env |mode |release)
          :examples $ []
        |site $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def site $ {} (:storage-key |workflow) (:relay-url |ws://127.0.0.1:9001) (:relay-channel |genui)
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
              reset! *reel $ reel-updater updater @*reel op
          :examples $ []
        |ensure-relay! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn ensure-relay! () $ when (nil? @*ws)
              dispatch! $ :: :relay-status |connecting nil
              let
                  ws $ new js/WebSocket (:relay-url config/site)
                  client-id $ str |renderer-
                    .!toISOString $ new js/Date
                reset! *ws ws
                .!addEventListener ws |open $ fn (event)
                  send-relay-frame! ws $ {} (:kind |hello) (:role |browser) (:client_id client-id)
                    :channels $ [] (:relay-channel config/site)
                .!addEventListener ws |message $ fn (event)
                  handle-relay-message! ws $ .-data event
                .!addEventListener ws |error $ fn (event)
                  dispatch! $ :: :relay-status |error "|Relay websocket error"
                .!addEventListener ws |close $ fn (event) (reset! *ws nil)
                  dispatch! $ :: :relay-status |closed "|Relay connection closed, retrying..."
                  flipped js/setTimeout 2000 ensure-relay!
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
                if (= kind |hello-ok)
                  dispatch! $ :: :relay-connected (:client_id frame)
                  if (= kind |event)
                    if
                      = (:channel frame) (:relay-channel config/site)
                      handle-genui-event! ws frame
                      do |ignored
                    if (= kind |error)
                      dispatch! $ :: :relay-status |error
                        or (:error frame) "|Relay error"
                      do |ignored
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
              :relay $ {} (:status |idle) (:client-id nil) (:last-error nil)
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
                (:relay-connected client-id)
                  -> store
                    assoc-in ([] :relay :status) |ready
                    assoc-in ([] :relay :client-id) client-id
                    assoc-in ([] :relay :last-error) nil
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
