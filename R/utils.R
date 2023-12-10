string_to_id <- \(str){
  str |>
    gsub(" ", "_", x = _) |>
    gsub("[[:punct:]]", "_", x = _) |>
    tolower()
}
