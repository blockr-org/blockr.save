storage <- new.env(hash = TRUE)

.onLoad <- function(...){
  storage$store <<- list(
    tabs = list(),
    stacks = list()
  )
}
