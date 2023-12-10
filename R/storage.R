storage <- new.env()
storage$store <- list(
  tabs = list(),
  stacks = list()
)

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
    custom = custom
  )
}

get_env <- \(){
  storage$store
}

write_json <- \(env){
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

serialise_env <- \(fn = write_json){
  fn(get_env())
}
