#' Run the Shiny Application
#'
#' @param ... A series of options to be used inside the app.
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  ...
) {
  options(mapbox.accessToken = Sys.getenv("MAPBOX_ACCESS_TOKEN"))
  with_golem_options(
    app = shinyApp(
      ui = app_ui, 
      server = app_server,
      options = list(...)
    ), 
    golem_opts = list(...)
  )
}
