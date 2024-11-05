#' Codelist
#' @field coding_system String, specifying the coding system of the codelist.
#' @field full_slug Full slug of the codelist from OpenCodelists.
#' @return New instance of class Codelist
#' @keywords internal
#' @importFrom S7 new_class class_data.frame class_character
Codelist <- S7::new_class("Codelist",
  parent = S7::class_data.frame,
  properties = list(
    coding_system = S7::class_character,
    full_slug = S7::class_character
  )
)

#' Helper function to get the organisation for a codelist from OpenCodelists
#' This is important to use the API from OpenCodelists
#' @keywords internal
get_codelist_organisation <- function(codelist_slug) {
  first_part <- stringr::str_extract(codelist_slug, "^[^/]+")
  if (!first_part == "user") {
    first_part
  } else {
    all_parts <- stringr::str_split(codelist_slug, "/")
    paste(all_parts[[1]][1], all_parts[[1]][2], sep = "/")
  }
}

#' Get codelist from OpenCodelists
#'
#' @param codelist_slug String, specifying the slug of the codelist.
#' The naming convention of the codelist slug follows this structure: a `<codelist-id>` is followed by / and a `<version-id>`.
#' Note that the version ID is a sequence of 8 characters.
#' Some codelists may also have a version tag in the form of a date (YYYY-MM-DD) or a version number (e.g., v1.2) that can be used in place of the version ID.
#' @export
#'
get_codelist <- function(codelist_slug) {
  codelist_slug <- sub("/$", "", codelist_slug)
  url_api_base <- "https://www.opencodelists.org/api/v1/codelist/"
  url_download_base <- "https://www.opencodelists.org/codelist/"
  url_download <- paste0(url_download_base, codelist_slug, "/download.csv")

  codelist_org <- get_codelist_organisation(codelist_slug)
  url_request <- paste0(url_api_base, codelist_org)

  request <- httr2::request(url_request) |>
    httr2::req_url_query(`include-users` = "true")

  response <- httr2::req_perform(request)
  response_json <- response |> httr2::resp_body_json()

  codelists_dfr <- response_json$codelists |>
    purrr::map_dfr(~ {
      coding_system_id <- .x$coding_system_id
      purrr::map_dfr(.x$versions, ~ tibble::tibble(
        coding_system_id = coding_system_id,
        full_slug = .x$full_slug
      ))
    })

  codelist_info <- codelists_dfr |>
    dplyr::filter(full_slug == codelist_slug) |>
    as.vector()

  codelist_dfr <- readr::read_csv(url_download,
    col_types = readr::cols(.default = readr::col_character())
  ) |>
    dplyr::rename(code = 1)

  Codelist(
    codelist_dfr,
    coding_system = codelist_info$coding_system_id,
    full_slug = codelist_info$full_slug
  )
}
