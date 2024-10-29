library(shiny)
library(bslib)
library(bsicons)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)
library(here)

ui <- page_sidebar(
  theme = bs_theme(version = 5, bootswatch = "lumen"),
  title = "Clinical Activity Explorer",
  sidebar = sidebar(
    selectInput("dataset", "Select dataset:",
                choices = c(
                  "SNOMED-CT" = "snomed",
                  "ICD-10" = "icd10")
    ),
    selectizeInput(
      "code_search",
      "Search by code:",
      choices = NULL,
      multiple = TRUE,
      options = list(maxOptions = 15)),
    textInput(
      "description_search",
      "Search by description:",
      ""),
    card(
      card_header("Upload from OpenCodelists"),
      textInput(
        "codelist_id",
        "Enter Codelist ID:",
        placeholder = "nhsd-primary-care-domain-refsets/bp_cod",
        NULL),
      textInput(
        "codelist_version_tag",
        "Enter Version Tag/ID:",
        placeholder = "20200812",
        NULL),
      actionButton("load_codelist", "Load codelist", class = "btn-primary")
    )
  ),
  layout_columns(
    value_box(
      title = "Number of selected codes",
      value = textOutput("unique_codes"),
      showcase = bs_icon("file-earmark-medical")
    ),
    value_box(
      title = "Total number of recorded events",
      value = textOutput("total_activity"),
      showcase = plotlyOutput("sparkline")
    )
  ),
  navset_card_tab(
    nav_panel(
      p(bs_icon("file-earmark-spreadsheet"), "Usage table"),
      DTOutput("usage_table")
    ),
    nav_panel(
      p(bs_icon("graph-up"), "Trends over time"),
      checkboxInput(
        "show_individual_codes",
        "Show individual codes (if <= 500)",
        value = FALSE)
      ,
      plotlyOutput("usage_plot")
    ),
    nav_panel(
      p(bs_icon("file-earmark-medical"), "Codelist"),
      DTOutput("codes_table")
    )
  )
)