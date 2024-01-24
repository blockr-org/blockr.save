#' blockApp
#'
#' An application that uses blocks and will restore state.
#'
#' @param app App object.
#' @param ui App UI function.
#' @param server App server function.
#' @param get_config Function that returns the configuration.
#' @param restore_tabs Function that restores the tabs.
#' @param save_config Function that saves the configuration.
#' @param custom Cumstom function to run after restoring tabs.
#'  Must accept `config`, `input`, `output`, and `session` arguments.
#' @param ... passed to [shiny::shinyApp()]
#'
#' @name save
#'
#' @keywords internal
with_blockr_app <- \(
  app, 
  save_config = save_json,
  get_config = get_json,
  restore_tabs = bs_restore_tabs,
  custom = NULL
){
  server_fn <- app$serverFuncSource()

  app$serverFuncSource <- \(){
    \(input, output, session){
      shiny::onStop(\(){
        cat("saving to config\n")
        set_blockr()
        save_config(get_env(), session, getOption("query"))
      })

      conf <- tryCatch(
        get_config(session, getOption("query")),
        error = \(e) NULL,
        warning = \(w) NULL
      )

      if(is.null(conf)){
        cat("No config found\n")
        return(build_app(server_fn, input, output, session))
      }

      cat("loading from config\n")

      conf <- parse_blockr(conf)
      init_conf(conf)

      restore_tabs(conf, input, output, session)

      # it's probably best to run the custom restore
      # function AFTER we've launched the app.
      # it is probably assumed that the objects are in the
      # DOM, etc.
      if(!is.null(custom))
        shiny::observeEvent(input$blockrSaveLoaded, {
          cat("Running custom restore callback\n")
          custom(conf, input, output, session)
        })

      build_app(server_fn, input, output, session)
    }
  }

  return(app)
}

#' @rdname save
#' @export
blockr_app <- \(
  ui, 
  server, 
  save_config = save_json,
  get_config = get_json, 
  restore_tabs = bs_restore_tabs,
  custom = NULL,
  ...
){
  ui_ <- \(req){
    query_params <- shiny::parseQueryString(req$QUERY_STRING)
    options("query" = query_params)

    if(is.function(ui))
      ui <- ui(req)

    attach_dependency(ui)
  }

  shiny::shinyApp(ui_, server, ...) |>
    with_blockr_app(
      save_config = save_config,
      get_config = get_config,
      restore_tabs = restore_tabs,
      custom = custom
    )
}

build_app <- function(server_fn, input, output, session){
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

  return(app)
}
