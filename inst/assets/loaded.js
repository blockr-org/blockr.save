$(document).on("shiny:connected", () => {
  Shiny.setInputValue("blockrSaveLoaded", true);
});
