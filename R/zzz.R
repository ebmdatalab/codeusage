.onLoad <- function(...) {
  S7::methods_register()
}

utils::globalVariables(c(
  "start_date",
  "end_date",
  "snomed_concept_id",
  "description",
  "usage",
  "icd10_code",
  "opcs_code",
  "total_usage",
  "full_slug"
))
