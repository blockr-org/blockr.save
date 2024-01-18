dependencies <- \(){
  htmltools::htmlDependency(
    name = "blockr.save",
    version = utils::packageVersion("blockr.save"),
    src = "assets",
    script = "loaded.js",
    package = "blockr.save"
  )
}

attach_dependency <- \(ui){
  htmltools::attachDependencies(ui, dependencies())
}
