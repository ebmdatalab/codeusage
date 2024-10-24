
<!-- README.md is generated from README.Rmd. Please edit that file -->

# codeusage: Code Usage in England

<!-- badges: start -->

<!-- badges: end -->

The goal of `codeusage` is to make yearly summaries of **SNOMED Code
Usage in Primary Care** published by NHS Digital available in R for
research. The original data is available from NHS Digital at:

- [SNOMED Code Usage in Primary
  Care](https://digital.nhs.uk/data-and-information/publications/statistical/mi-snomed-code-usage-in-primary-care)

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
