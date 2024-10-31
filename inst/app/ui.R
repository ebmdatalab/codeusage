library(shiny)
library(bslib)
library(bsicons)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)
library(here)

foot_data_source <- popover(
  actionLink("link", "Data sources"),
  a("SNOMED-CT", href = "https://digital.nhs.uk/data-and-information/publications/statistical/mi-snomed-code-usage-in-primary-care"), "; ",
  a("ICD-10", href = "https://digital.nhs.uk/data-and-information/publications/statistical/hospital-admitted-patient-care-activity")
)

ui <- page_sidebar(
  theme = bs_theme(version = 5, bootswatch = "lumen"),
  title = "Code Usage Explorer",
  sidebar = sidebar(
    card(
      card_header("Select dataset"),
      radioButtons("dataset", NULL,
                choices = c(
                  "SNOMED-CT" = "snomed",
                  "ICD-10" = "icd10")
    ),
    card_footer(foot_data_source)),
    card(
      card_header("Search"),
    selectizeInput(
      "code_search",
      "Code:",
      choices = NULL,
      multiple = TRUE,
      options = list(maxOptions = 15)),
    textInput(
      "description_search",
      "Description:",
      "")),
    card(
      card_header("Upload OpenCodelist"),
      textInput(
        "codelist_id",
        tooltip(
          span(
            "Codelist URL",
            bs_icon("info-circle")
          ),
          "Enter the entire URL to codlist, e.g., https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bp_cod/20200812/",
          options = list(
            customClass = "left-align-tooltip"
          )
        ),
        placeholder = "https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bp_cod/20200812/",
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
        tooltip(
          span(
            "Show individual codes",
            bs_icon("info-circle")
          ),
          "This is only supported for up to 500 selected codes.",
          placement = "right"
        ),
        value = FALSE)
      ,
      plotlyOutput("usage_plot")
    ),
    nav_panel(
      p(bs_icon("file-earmark-medical"), "Selected codes"),
      DTOutput("codes_table")
    )
  ),
  tags$style(HTML("
    .left-align-tooltip .tooltip-inner {
      text-align: left;
      max-width: 300px;
    }
  "))
)
