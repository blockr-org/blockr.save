#' Restore Tabs
#' 
#' Restore tabs from a config object.
#' 
#' @param config A config object.
#' @param input,output,session Shiny parameters.
#' @param query A parsed query string.
#' 
#' @export
bs_restore_tabs <- \(config, input, output, session, query) {
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
