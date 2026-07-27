{}
  :type |column
  :children $ []
    {} (:type |card) (:text "|Weekly Report")
      :children $ []
        {} (:type |text) (:text "|System health summary")
        {} (:type |badge) (:text |healthy)
        {} (:type |divider)
        {} (:type |markdown) (:text "|## Notes\n- renderer ok\n- relay ok\n> investigate warnings later")
    {} (:type |row)
      :children $ []
        {} (:type |chart) (:kind |line) (:title "|Traffic")
          :series $ []
            {} (:label |Mon) (:value 120)
            {} (:label |Tue) (:value 132)
            {} (:label |Wed) (:value 148)
        {} (:type |mermaid) (:text "|flowchart LR\n  CLI --> Relay\n  Relay --> Renderer\n  Renderer --> Browser")