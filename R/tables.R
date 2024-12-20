#' Helper function to create code usage table
#' @importFrom DT datatable formatPercentage
#' @keywords internal
datatable_usage <- function(data) {
  datatable(data,
    colnames = c("Code", "Description", "Usage", "Percentage"),
    rownames = FALSE,
    options = list(
      columnDefs = list(
        list(width = "60px", targets = 0),
        list(width = "350px", targets = 1),
        list(width = "60px", targets = 2),
        list(width = "40px", targets = 3)
      ),
      pageLength = 10,
      scrollX = TRUE,
      searching = FALSE
    )
  ) |>
    formatPercentage(
      "total_pct",
      digits = 3
    )
}


#' Helper function to create codelist / selected codes table
#' @importFrom DT datatable
#' @keywords internal
datatable_codelist <- function(data, data_desc) {
  datatable(data,
    colnames = c("Code", "Description"),
    rownames = FALSE,
    extensions = c("Buttons", "Scroller"),
    options = list(
      columnDefs = list(
        list(width = "50px", targets = 0),
        list(width = "500px", targets = 1)
      ),
      pageLength = 20,
      scrollX = TRUE,
      searching = FALSE,
      dom = "Bfrtip",
      buttons = list(
        "copy",
        list(
          extend = "csv",
          title = paste0("selected_", data_desc, "_codes")
        )
      ),
      deferRender = TRUE,
      scrollY = 400,
      scroller = TRUE
    )
  )
}
