# blockr.save

Utilities to serialise and deserialise blockr applications.

## Installation

```r
# install.packages("remotes")
remotes::install_github("blockr/blockr.save")
```

## Example

All functionalities are packed in `blockr_app()` which should be called 
instead of `shiny::shinyApp()`.

The application will save the state of the app in a `.blockr` file 
when the session ends.

```r
library(shiny)
library(blockr.save)

stack <- new_stack(
  data_block
)

ui <- fluidPage(
    "blockr.save",
    blockr::generate_ui(stack)
)

server <- function(...){
    blockr::generate_server(stack)
}

blockr_app(ui, server)
```

