devtools::load_all()
library(shiny)
library(blockr)

options(shiny.port = 3000)

stack <- new_stack(
  data_block
)

restore_tabs_mason <- \(conf){
  bs_restore_tabs(conf)
  purrr::walk(conf$tabs$tabs, \(tab) {
    print(tab$id)
    masonry::mason(sprintf("#%sGrid", tab$id), delay = 2 * 1000)
    add_stack <- blockr.ui::add_stack_server(
      sprintf("%sAdd", tab$id),
      delay = 2 * 1000
    )

    observeEvent(add_stack$dropped(), {
      print(add_stack$dropped())
    })
  })
}

insert_block_tab <- \(title){
  id <- string_to_id(title)
  grid_id <- sprintf("%sGrid", id)

  on.exit({
    masonry::mason(sprintf("#%s", grid_id), delay = 2 * 1000)
  })

  tab <- tagList(
    h1(title),
    blockr.ui::addStackUI(
      sprintf("%sAdd", id), 
      ".masonry-row"
    ),
    masonry::masonryGrid(
      id = grid_id,
      masonry::masonryRow(classes = "bg-success"),
      styles = list(
        rows = list(
          `min-height` = "5rem"
        ),
        items = list(
          margin = "1rem"
        )
      )
    )
  )

  set_tab(
    title, 
    id = id,
    content = tab
  )

  insertTab(
    "nav",
    tabPanel(
      title,
      id = id,
      tab
    )
  )

  add_stack <- blockr.ui::add_stack_server(
    sprintf("%sAdd", id),
    delay = 2 * 1000
  )

  observeEvent(add_stack$dropped(), {
    print(add_stack$dropped())
  })
}

ui <- navbarPage(
  "blockr.save",
  theme = bslib::bs_theme(),
  id = "nav",
  header = list(
    blockr.ui:::dependency("stack"),
    masonry::masonryDependencies()
  ),
  tabPanel(
    "First", 
    id = "first",
    h1("title"),
    h2("subtitle"),
    textInput("title", "Tab title"),
    actionButton("add", "Add tab"),
    generate_ui(stack)
  )
)

server <- \(input, output, session){
  generate_server(stack)
  set_tab_id("nav")

  observeEvent(input$add, {
    insert_block_tab(input$title)
  })
}

block_app(ui, server, enableBookmarking = "url", restore_tabs = restore_tabs_mason)
