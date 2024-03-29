#' Reset Config
#' 
#' Reset configuration
#' 
#' @export
reset_conf <- \(){
  storage$store <- list(
    tabs = list(),
    stacks = list()
  )
}

#' Parse serialised worksplace
#' 
#' Parse serialised worksplace and store in environment.
#' 
#' @param conf The config object.
#' @param ... Ignored.
#' 
#' @export
parse_blockr <- \(conf, ...) UseMethod("parse_blockr", conf)

#' @export
parse_blockr.default <- \(conf, ...){
  return(conf)
}

#' @export
parse_blockr.blockr_conf <- \(conf, ...){
  conf$workspace <- blockr::from_json(conf$workspace)
  return(conf)
}

#' Store loaded config
#' 
#' Store the initially loaded config in the storage environment.
#' 
#' @param conf The config object.
#' 
#' @keywords internal
init_conf <- \(conf){
  storage$store <- conf
}

# idially we'd remove this
# can be picked up from UI
# we send to server and send
#' Set Tab ID
#' 
#' Set tab id, the `id` you use for the navbar navigation.
#' 
#' @param id ID of navigation.
#' 
#' @export
set_tab_id <- \(id){
  storage$store$tabs$id <- id
}

#' Set tab data
#' 
#' Set a tab's data in the storage environment.
#' 
#' @param label The tab's label.
#' @param ... The tab's stacks.
#' @param content The tab's content, other than stacks.
#' @param id ID of tab.
#' @param custom Custom tab data to use with a custom restore function.
#' 
#' @export
set_tab <- \(label, ..., content = list(), id = label, custom = list()) {
  content <- as.character(content)

  if(length(content) == 0L)
    content <- ""

  storage$store$tabs$tabs[[id]] <- list(
    label = label, 
    id = id, 
    content = content,
    stacks = list(...),
    custom = custom,
    masonry = list()
  )
}

#' Remove tab data
#' 
#' Remove a tab's data in the storage environment.
#' 
#' @param id ID of tab.
#' 
#' @export
rm_tab <- \(id) {
  stopifnot(!missing(id))
  storage$store$tabs$tabs <- storage$store$tabs$tabs[names(storage$store$tabs$tabs) != id]
}

#' Set masonry config
#' 
#' Set masonry config for a tab in the storage environment.
#' 
#' @param tabid ID of tab.
#' @param conf Masonry config.
#' 
#' @export
set_masonry <- \(tabid, conf){
  storage$store$tabs$tabs[[tabid]]$masonry <- conf
}

#' Set blockr workspace
#' 
#' Set blockr workspace in environment.
#' 
#' @export
set_blockr <- \(){
  ws <- blockr::get_workspace()
  storage$store$workspace <- ws |>
    ls() |>
    lapply(get, envir = ws)

  names(storage$store$workspace) <- ws |>
    ls()
}

#' Get Storage
#' 
#' Get storage environment
#' 
#' @export
get_env <- \(){
  storage$store
}

#' Save the config to a JSON file
#' 
#' Save the config to a JSON file.
#' 
#' @param env The config environment.
#' @param query Parsed query string.
#' @param session  A shiny session.
#' 
#' @name json
#' 
#' @export
save_json <- \(env, session, query){
  env$store$workspace <- blockr::to_json(env$store$workspace)

  jsonlite::write_json(
    env, 
    ".blockr", 
    dataframe = "rows", 
    auto_unbox = TRUE, 
    pretty = TRUE
  )
}

#' @rdname json
#' @export
get_json <- \(session, query){
  jsonlite::read_json(".blockr") |>
    structure(class = "blockr_conf")
}

#' Save the config to an RData file
#' 
#' Save the config to an RData file.
#' 
#' @param env The config environment.
#' @param query Parsed query string.
#' @param session  A shiny session.
#' 
#' @name json
#' 
#' @export
save_rdata <- \(env, session, query){
  save(
    env,
    file = ".blockr"
  )
}

#' @rdname json
#' @export
get_rdata <- \(session, query){
  get(load(".blockr"))
}
