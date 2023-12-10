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
    print(sprintf("#%s-grid", string_to_id(tab$id)))
    masonry::mason(sprintf("#%s-grid", string_to_id(tab$id)), delay = 2 * 1000)
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
    id <- sprintf("%s-grid", string_to_id(input$title))

    on.exit({
      masonry::mason(sprintf("#%s", id), delay = 2 * 1000)
    })

    insertTab(
      "nav",
      tabPanel(
        input$title,
        id = tolower(input$title),
        h1(input$title),
        blockr.ui::addStackUI(
          sprintf("%s-add", string_to_id(input$title)), 
          ".masonry-row"
        ),
        masonry::masonryGrid(
          id = id,
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
      sprintf("%s-add", string_to_id(input$title)),
      delay = 2 * 1000
    )

    set_tab(
      input$title, 
      id = tolower(input$title),
      content = tagList(
        h1(input$title),
        blockr.ui::addStackUI(string_to_id(input$title), ".masonry-row"),
        masonry::masonryGrid(
          id = id,
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
