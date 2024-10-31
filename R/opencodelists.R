#' Get codelist from OpenCodelists
#'
#' @param codelist_url String, specifying URL to the codelist on OpenCodelists
#' @export
#'
get_opencodelist <- function(codelist_url) {
  get_download_url <- function(codelist_url) {
    if (stringr::str_ends(codelist_url, "/")) {
      return(paste0(codelist_url, "download.csv"))
    } else {
      return(paste0(codelist_url, "/download.csv"))
    }
  }

  data <- tryCatch(
    {
      req <- httr2::request(get_download_url(codelist_url))
      response <- httr2::req_perform(req)

      response |>
        httr2::resp_body_string() |>
        readr::read_csv(
          col_types = readr::cols(.default = readr::col_character())
        ) |>
        dplyr::rename(code = 1)
    },
    error = function(e) {
      stop("Error downloading codelist: ", e$message)
    }
  )

  return(data)
}
