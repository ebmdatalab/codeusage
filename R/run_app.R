#' Interactive tool to explore clinical code usage
#'
#' @export
run_explore_code_usage <- function() {
  shiny::shinyApp(
    ui = app_ui,
    server = app_server,
  )
}
