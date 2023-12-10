#' Restore Tab
restore_tabs <- \(config) {
  purrr::walk(config$tabs$tabs, \(tab){
    insertTab(
      config$tab$id,
      tabPanel(
        tab$label,
        id = tab$id,
        HTML(tab$content)
      )
    )
  })
}
