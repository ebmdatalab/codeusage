.onLoad <- function(...) {
  S7::methods_register()
}

utils::globalVariables(c(
  "annual_proportion",
  "start_date",
  "end_date",
  "snomed_code",
  "description",
  "usage",
  "icd10_code",
  "opcs4_code",
  "total_usage",
  "full_slug"
))
