
<!-- README.md is generated from README.Rmd. Please edit that file -->

# codeusage

<!-- badges: start -->

[![R-CMD-check](https://github.com/ebmdatalab/codeusage/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ebmdatalab/codeusage/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

The goal of `codeusage` is to make yearly summaries of **SNOMED CodevUsage in Primary Care** and **ICD-10 and OPCS Code Usage in SecondaryvCare** in England, published by NHS Digital, available in R forvresearch.
The interactive [Code Usage Explorer](https://milanwiedemann.shinyapps.io/codeusage/) app allows users to explore the data online.
The original data is available from NHS Digital at:

- [SNOMED Code Usage in Primary
  Care](https://digital.nhs.uk/data-and-information/publications/statistical/mi-snomed-code-usage-in-primary-care)
- [ICD-10 and OPCS Code Usage in Secondary
  Care](https://digital.nhs.uk/data-and-information/publications/statistical/hospital-admitted-patient-care-activity)

## Installation

You can install the development version of `codeusage` like so:

``` r
remotes::install_github("ebmdatalab/codeusage")
```

## Example

``` r
# Load codeusage package
library(codeusage)
```

### Dataset: SNOMED Code Usage in Primary Care in England

This is only a selection of the full dataset published by NHS Digital,
for the data pre-processing see `/data-raw/snomed_code_usage.R`.

``` r
# Return SNOMED code usage data
snomed_usage
#> # A tibble: 1,523,967 × 7
#>    start_date end_date   snomed_concept_id description     usage active_at_start
#>    <date>     <date>     <chr>             <chr>           <int> <lgl>          
#>  1 2023-08-01 2024-07-31 279991000000102   Short message… 4.41e8 TRUE           
#>  2 2023-08-01 2024-07-31 184103008         Patient telep… 1.91e8 TRUE           
#>  3 2023-08-01 2024-07-31 428481002         Patient mobil… 1.16e8 TRUE           
#>  4 2023-08-01 2024-07-31 423876004         Clinical docu… 7.81e7 TRUE           
#>  5 2023-08-01 2024-07-31 72313002          Systolic arte… 6.87e7 TRUE           
#>  6 2023-08-01 2024-07-31 1091811000000102  Diastolic art… 6.87e7 TRUE           
#>  7 2023-08-01 2024-07-31 1000731000000107  Serum creatin… 4.82e7 TRUE           
#>  8 2023-08-01 2024-07-31 60621009          Body mass ind… 4.65e7 TRUE           
#>  9 2023-08-01 2024-07-31 1000661000000107  Serum sodium … 4.63e7 TRUE           
#> 10 2023-08-01 2024-07-31 1000651000000109  Serum potassi… 4.62e7 TRUE           
#> # ℹ 1,523,957 more rows
#> # ℹ 1 more variable: active_at_end <lgl>
```

### Dataset: ICD-10 Code Usage in Secondary Care in England

This is the total annual count of the Finished Consultant Episodes (FCE)
listing each 4-character ICD-10 code either in primary or secondary
diagnosis position in the Hospital Episode Statistics in England.

This is only a selection of the full dataset published by NHS Digital,
for the data pre-processing see `/data-raw/icd10_usage.R`.

``` r
# Return ICD-10 code usage data
icd10_usage
#> # A tibble: 135,951 × 5
#>    start_date end_date   icd10_code description                            usage
#>    <date>     <date>     <chr>      <chr>                                  <int>
#>  1 2023-04-01 2024-03-31 A000       Cholera due to Vibrio cholerae 01, bi…     2
#>  2 2023-04-01 2024-03-31 A009       Cholera, unspecified                      40
#>  3 2023-04-01 2024-03-31 A010       Typhoid fever                            884
#>  4 2023-04-01 2024-03-31 A011       Paratyphoid fever A                      139
#>  5 2023-04-01 2024-03-31 A012       Paratyphoid fever B                       13
#>  6 2023-04-01 2024-03-31 A013       Paratyphoid fever C                        2
#>  7 2023-04-01 2024-03-31 A014       Paratyphoid fever, unspecified            68
#>  8 2023-04-01 2024-03-31 A020       Salmonella enteritis                    2165
#>  9 2023-04-01 2024-03-31 A021       Salmonella sepsis                        319
#> 10 2023-04-01 2024-03-31 A022       Localized salmonella infections           82
#> # ℹ 135,941 more rows
```

### Dataset: OPCS Code Usage in Secondary Care in England

This is the total annual count of each instance that each 4-character
OPCS code is listed across all primary and secondary procedure positions
in the Finished Consultant Episodes (FCE) of the Hospital Episode
Statistics in England.

This is only a selection of the full dataset published by NHS Digital,
for the data pre-processing see `/data-raw/opcs_usage.R`.

``` r
# Return OPCS code usage data
opcs_usage
#> # A tibble: 107,376 × 5
#>    start_date end_date   opcs_code description                             usage
#>    <date>     <date>     <chr>     <chr>                                   <int>
#>  1 2023-04-01 2024-03-31 A011      Hemispherectomy                             7
#>  2 2023-04-01 2024-03-31 A012      Total lobectomy of brain                   36
#>  3 2023-04-01 2024-03-31 A013      Partial lobectomy of brain                134
#>  4 2023-04-01 2024-03-31 A018      Other specified major excision of tiss…    27
#>  5 2023-04-01 2024-03-31 A019      Unspecified major excision of tissue o…     3
#>  6 2023-04-01 2024-03-31 A021      Excision of lesion of tissue of fronta…  1399
#>  7 2023-04-01 2024-03-31 A022      Excision of lesion of tissue of tempor…   971
#>  8 2023-04-01 2024-03-31 A023      Excision of lesion of tissue of pariet…   704
#>  9 2023-04-01 2024-03-31 A024      Excision of lesion of tissue of occipi…   260
#> 10 2023-04-01 2024-03-31 A025      Excision of lesion of tissue of cerebe…   604
#> # ℹ 107,366 more rows
```
