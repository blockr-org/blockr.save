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
    blockr.ui::add_stack_server(
      sprintf("%sAdd", tab$id),
      delay = 2 * 1000
    )
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
    id <- string_to_id(input$title)
    grid_id <- sprintf("%sGrid", id)

    on.exit({
      masonry::mason(sprintf("#%s", grid_id), delay = 2 * 1000)
    })

    insertTab(
      "nav",
      tabPanel(
        input$title,
        id = id,
        h1(input$title),
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
    )

    blockr.ui::add_stack_server(
      sprintf("%sAdd", id),
      delay = 2 * 1000
    )

    set_tab(
      input$title, 
      id = id,
      content = tagList(
        h1(input$title),
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
    )
  })
}

block_app(ui, server, enableBookmarking = "url", restore_tabs = restore_tabs_mason)
