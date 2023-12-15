storage <- new.env()
storage$store <- list(
  tabs = list(),
  stacks = list()
)

init_conf <- \(conf){
  storage$store <- conf
}

# will remove
# can be picked up from UI
# we send to server and send
set_tab_id <- \(id){
  storage$store$tabs$id <- id
}

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

set_masonry <- \(tabid, conf){
  storage$store$tabs$tabs[[tabid]]$masonry <- conf
}

get_env <- \(){
  storage$store
}

save_json <- \(env, input, output, session){
  jsonlite::write_json(
    env, 
    "config.json", 
    dataframe = "rows", 
    auto_unbox = TRUE, 
    pretty = TRUE
  )
}

get_json <- \(){
  jsonlite::read_json("config.json")
}
