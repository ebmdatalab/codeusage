#' Interactive tool to explore clinical code usage
#'
#' Launch Shiny app to explore clinical code usage.
#'
#' @export
run_explore_code_usage <- function() {
  app_dir <- system.file("inst/app", package = "codeusage")
  if (app_dir == "") {
    stop("Could not find the Shiny app directory. Try re-installing the package.")
  }
  shiny::runApp(app_dir, display.mode = "normal")
}
