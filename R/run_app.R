#' Interactive tool to explore clinical code usage
#'
#' @export
run_app <- function() {
  shiny::shinyApp(
    ui = app_ui,
    server = app_server,
  )
}
