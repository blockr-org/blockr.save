#' blockApp
#'
#' An application that uses blocks and will restore state.
#'
#' @param app App object.
#' @param ui App UI function.
#' @param server App server function.
#' @param get_config Function that returns the configuration.
#' @param restore_tabs Function that restores the tabs.
#' @param ... passed to [shiny::shinyApp()]
#'
#' @name save
#'
#' @export
with_block_app <- \(
  app, 
  get_config = get_json,
  restore_tabs = bs_restore_tabs
){
  server_fn <- app$serverFuncSource()

  app$serverFuncSource <- \(){
    \(input, output, session){
      # fails if user only uses input and output
      # if fails try without session
      args <- methods::formalArgs(server_fn)

      app <- NULL
      if(length(args) == 3L)
        app <- server_fn(input, output, session)
      
      if(length(args) == 2L)
        app <- server_fn(input, output)

      if(is.null(app))
        stop("server function must accept ui and server arguments")

      conf <- tryCatch(
        get_config(),
        error = \(e) NULL
      )
      
      session$onSessionEnded(\(){
        cat("saving to config\n")
        serialise_env()
      })

      if(is.null(conf)){
        warning("Could not get config")
        return(app)
      }

      cat("loading from config\n")

      init_conf(conf)

      restore_tabs(conf, input, output, session)

      return(app)
    }
  }

  return(app)
}

#' @rdname save
#' @export
block_app <- \(
  ui, 
  server, 
  get_config = get_json, 
  restore_tabs = bs_restore_tabs,
  ...
){
  shiny::shinyApp(ui, server, ...) |>
    with_block_app(
      get_config = get_config,
      restore_tabs = restore_tabs
    )
}
