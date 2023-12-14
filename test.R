devtools::load_all()
library(shiny)
library(blockr)

options(shiny.port = 3000)

stack <- new_stack(
  data_block
)

restore_tabs_custom <- \(conf, input, output, session){
  bs_restore_tabs(conf)
  purrr::walk(conf$tabs$tabs, \(tab) {
    grid_id <- sprintf("#%sGrid", tab$id)

    on.exit({
      masonry::mason(grid_id, delay = 2 * 1000)
      masonry::masonry_get_config(grid_id)
    })

    add_stack <- blockr.ui::add_stack_server(
      sprintf("%sAdd", tab$id),
      delay = 2 * 1000
    )

    observeEvent(add_stack$dropped(), {
      stack <- new_stack(
        data_block
      )

      masonry::masonry_add_item(
        grid_id,
        row_id = sprintf("#%s", add_stack$dropped()$target),
        item = generate_ui(stack)
      )

      stack_server <- generate_server(stack)
      masonry::masonry_get_config(grid_id)

      observeEvent(input[[sprintf("%s_config", grid_id)]], {
        print(input[[sprintf("%s_config", grid_id)]])
        set_masonry(tab$id, input[[sprintf("%s_config", grid_id)]])
      })
    })
  })
}

insert_block_tab <- \(title, input, output, session){
  id <- string_to_id(title)
  grid_id <- sprintf("%sGrid", id)

  on.exit({
    masonry::mason(sprintf("#%s", grid_id), delay = 2 * 1000)
    masonry::masonry_get_config(grid_id)
  })

  tab <- tagList(
    h1(title),
    blockr.ui::addStackUI(
      sprintf("%sAdd", id), 
      ".masonry-row"
    ),
    br(),
    masonry::masonryGrid(
      id = grid_id,
      masonry::masonryRow(classes = "bg-success"),
      styles = list(
        rows = list(
          `min-height` = "5rem"
        ),
        items = list(
          margin = ".5rem"
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
    stack <- new_stack(
      data_block
    )

    masonry::masonry_add_item(
      sprintf("#%s", grid_id),
      row_id = sprintf("#%s", add_stack$dropped()$target),
      item = generate_ui(stack)
    )

    stack_server <- generate_server(stack)

    observeEvent(input[[sprintf("%s_config", grid_id)]], {
      print(input[[sprintf("%s_config", grid_id)]])
      set_masonry(tab$id, input[[sprintf("%s_config", grid_id)]])
    })
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
    insert_block_tab(input$title, input, output, session)
  })
}

block_app(ui, server, enableBookmarking = "url", restore_tabs = restore_tabs_custom)
