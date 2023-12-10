#' blockApp
#'
#' An application that uses blocks and will restore state.
#'
#' @param app App object.
#' @param ui App UI function.
#' @param server App server function.
#' @param config Function that returns the configuration.
#'
#' @export
with_block_app <- \(app, config = get_json){
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
        config(),
        error = \(e) NULL
      )

      if(is.null(conf)){
        warning("Could not get config")
        return(app)
      }

      cat("loading from config\n")

      session$onSessionEnded(\(){
        cat("saving to config\n")
        serialise_env()
      })

      restore_tabs(conf)

      return(app)
    }
  }

  return(app)
}

block_app <- \(ui, server, config = get_json, ...){
  shiny::shinyApp(ui, server, ...) |>
    with_block_app(config = config)
}
