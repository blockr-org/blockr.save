storage <- new.env()
storage$store <- list(
  tabs = list(),
  stacks = list()
)

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

get_env <- \(){
  storage$store
}

#' Save the config to a JSON file
#' 
#' Save the config to a JSON file.
#' 
#' @param env The config environment.
#' @param query Parsed query string.
#' 
#' @name json
#' 
#' @export
save_json <- \(env, query){
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
get_json <- \(query){
  jsonlite::read_json(".blockr")
}
