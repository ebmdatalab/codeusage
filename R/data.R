#' @importFrom tibble tibble
NULL

#' Yearly SNOMED-CT Code Usage in Primary Care in England
#'
#' Yearly summary of SNOMED-CT code usage from 1st August 2011 to 31st July 2023.
#' The variables in this dataset include:
#' @format A data frame with 1,366,513 rows and 6 columns:
#' \describe{
#'   \item{start_date}{Start date of code usage count}
#'   \item{end_date}{End date of code usage count}
#'   \item{snomed_concept_id}{SNOMED Concept ID}
#'   \item{usage}{Yearly summary of code usage.
#'   Note that counts are rounded to the nearest 10.
#'   Counts of 5 or below are displayed as 5.}
#'   \item{active_at_start}{Specifying whether code was active at the start date.}
#'   \item{active_at_end}{Specifying whether code was active at the end date.}
#'   \item{description}{Description of SNOMED Concept ID}
#' }
#' @source <https://digital.nhs.uk/data-and-information/publications/statistical/mi-snomed-code-usage-in-primary-care>
#' @examples
#' # Filter for code usage records from 2022-08-01 onwards
#' snomed_usage |>
#'   dplyr::filter(start_date >= "2022-08-1")
#' 
#' # Filter for code usage records from 2022-08-01 onwards
#' # where the description contains the word "anxiety"
#' snomed_usage |>
#'   dplyr::filter(start_date >= "2022-08-1") |>
#'   dplyr::filter(grepl("anxiety", description, ignore.case = TRUE))
"snomed_usage"

#' Yearly ICD-10 Code Usage from Hospital Admitted Patient Care Activity in England
#'
#' Yearly summary of ICD-10 code usage from 1st April 2013 to 31st March 2024.
#' All diagnosis codes are summarised to the 4-character level.
#' The code usage represents the total annual count of episodes which record in any primary or secondary position.
#' Restricted codes for which annual usage is not published, have been removed.
#' @format A data frame with 135,951 rows and 5 columns:
#' \describe{
#'   \item{start_date}{Start date of code usage count}
#'   \item{end_date}{End date of code usage count}
#'   \item{icd10_code}{The 4-character ICD-10 Code.
#'   Note that the punctuation from the code has been removed for compatibility with OpenCodelists.}
#'   \item{usage}{Yearly summary of code usage.}
#'   \item{description}{Description of ICD-10 Code}
#' }
#' @source <https://digital.nhs.uk/data-and-information/publications/statistical/hospital-admitted-patient-care-activity>
"icd10_usage"

#' Yearly OPCS Code Usage from Hospital Admitted Patient Care Activity in England
#'
#' Yearly summary of OPCS code usage from 1st April 2013 to 31st March 2024.
#' All procedure codes are summarised to the 4-character level.
#' The code usage represents total annual count of each procedure, recorded across the primary and the secondary procedure positions.
#' Restricted codes for which annual usage is not published, have been removed.
#' @format A data frame with 107,376 rows and 5 columns:
#' \describe{
#'   \item{start_date}{Start date of code usage count}
#'   \item{end_date}{End date of code usage count}
#'   \item{opcs_code}{The 4-character OPCS code.
#'   Note that the punctuation from the code has been removed for compatibility with OpenCodelists.}
#'   \item{usage}{Yearly summary of code usage.}
#'   \item{description}{Description of OPCS Code}
#' }
#' @source <https://digital.nhs.uk/data-and-information/publications/statistical/hospital-admitted-patient-care-activity>
"opcs_usage"
