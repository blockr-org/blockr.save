#' Restore Tabs
#' 
#' Restore tabs from a config object.
#' 
#' @param config A config object.
#' 
#' @export
bs_restore_tabs <- \(config) {
  purrr::walk(config$tabs$tabs, \(tab){
    shiny::insertTab(
      config$tab$id,
      shiny::tabPanel(
        tab$label,
        id = tab$id,
        shiny::HTML(tab$content)
      )
    )
  })
}
