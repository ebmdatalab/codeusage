#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#' @noRd
#' @import shiny
#' @import bslib
#' @import bsicons
#' @importFrom DT DTOutput
#' @importFrom plotly plotlyOutput


app_ui <- function(request) {
  page_sidebar(
    theme = bs_theme(version = 5, bootswatch = "lumen"),
    title = "Code Usage Explorer",
    sidebar = sidebar(
      card(
        card_header("Select dataset"),
        radioButtons("dataset", NULL,
          choices = c(
            "SNOMED-CT" = "snomed",
            "ICD-10" = "icd10",
            "OPCS" = "opcs"
          )
        )
      ),
      card(
        card_header("Select codes"),
        selectizeInput(
          "code_search",
          "Specific code",
          choices = NULL,
          multiple = TRUE,
          options = list(maxOptions = 15)
        ),
        textInput(
          "description_search",
          "Description",
          ""
        )
      ),
      card(
        card_header(
          tooltip(
            span(
              "Load from OpenCodelist",
              bs_icon("info-circle")
            ),
            "Enter <codelist_id>/<version_id>, for example: 'nhsd-primary-care-domain-refsets/bp_cod/20200812'",
            options = list(
              customClass = "left-align-tooltip"
            )
          )
        ),
        textInput(
          "codelist_slug",
          "Codelist ID / Version Tag",
          placeholder = "nhsd-primary-care-domain-refsets/bp_cod/20200812",
          NULL
        ),
        actionButton("load_codelist", "Load codelist", class = "btn-primary")
      ),
      width = "20%"
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
          value = FALSE
        ),
        plotlyOutput("usage_plot")
      ),
      nav_panel(
        p(bs_icon("file-earmark-spreadsheet"), "Usage table"),
        DTOutput("usage_table")
      ),
      nav_panel(
        p(bs_icon("file-earmark-medical"), "Selected codes"),
        DTOutput("codes_table")
      )
    ),
    tags$style(HTML("
      .left-align-tooltip .tooltip-inner {
        text-align: left;
        max-width: 500px;
      }
      .card-header {
        font-weight: bold;
      }
    "))
  )
}
