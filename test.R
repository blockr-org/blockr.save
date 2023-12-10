devtools::load_all()
library(shiny)
library(blockr)

options(shiny.port = 3000)

stack <- new_stack(
  data_block
)

ui <- navbarPage(
  theme = bslib::bs_theme(),
  "test app",
  id = "nav",
  tabPanel(
    "First", 
    id = "first",
    textInput("title", "Tab title"),
    actionButton("add", "Add tab"),
    h1("title"),
    h2("suibtitle"),
    generate_ui(stack)
  )
)

server <- \(input, output, session){
  generate_server(stack)
  set_tab_id("nav")

  observeEvent(input$add, {
    insertTab(
      "nav",
      tabPanel(
        input$title,
        id = tolower(input$title),
        h1("Tab")
      )
    )

    set_tab(input$title, content = h1("Tab"), id = tolower(input$title))
  })
}

block_app(ui, server, enableBookmarking = "url")
