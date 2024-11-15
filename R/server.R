#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#' @noRd
#' @import shiny
#' @import bslib
#' @import bsicons
#' @import dplyr
#' @import ggplot2
#' @importFrom scales comma label_date_short label_comma
#' @importFrom lubridate month year
#' @importFrom DT renderDT datatable
#' @importFrom plotly renderPlotly ggplotly plot_ly config add_lines layout
#' @import here

app_server <- function(input, output, session) {
  # DATA: Selected code usage dataset
  selected_data <- reactive({
    if (input$dataset == "snomedct") {
      codeusage::snomed_usage |>
        select(start_date, end_date, code = snomed_concept_id, description, usage)
    } else if (input$dataset == "icd10") {
      codeusage::icd10_usage |>
        select(start_date, end_date, code = icd10_code, description, usage)
    } else if (input$dataset == "opcs") {
      codeusage::opcs_usage |>
        select(start_date, end_date, code = opcs_code, description, usage)
    }
  })

  # Update choices
  observe({
    updateSelectizeInput(
      session, "code_search",
      choices = unique(selected_data()$code),
      server = TRUE
    )
  })

  # DATA: OpenCodelist
  selected_codelist <- reactive({
    req(input$codelist_slug)

    withProgress(message = "Loading codelist ...", {
      tryCatch(
        {
          codelist_s7 <- get_codelist(input$codelist_slug)

          if (codelist_s7@coding_system == input$dataset) {
            showNotification(
              paste0("Successfully loaded ", codelist_s7@coding_system, " codelist."),
              type = "default"
            )
          } else {
            showNotification(
              paste0("Loaded codelist (", codelist_s7@coding_system, ") does not match selected data (", input$dataset, ")."),
              type = "error"
            )
          }


          codelist_s7 |>
            tibble::as_tibble() |>
            dplyr::select(1:2)
        },
        error = function(e) {
          showNotification(
            sprintf("Error loading Codelist: %s", conditionMessage(e)),
            type = "error"
          )
          NULL
        }
      )
    })
  }) |>
    bindEvent(input$load_codelist)

  # DATA: Filtered usage data
  
  filtered_data <- reactive({
    req(selected_data())

    withProgress(message = "Filtering data ...", {
      data <- selected_data()

      if (!is.null(input$code_search) && length(input$code_search) > 0) {
        data <- data |>
          filter(code %in% input$code_search)
      }

      if (!is.null(input$description_search) && input$description_search != "") {
        data <- data |>
          filter(grepl(input$description_search, description, ignore.case = TRUE))
      }

      if (!is.null(selected_codelist())) {
        data <- data |>
          filter(code %in% selected_codelist()$code)
      }

      if (nrow(data) == 0) {
        showNotification("No data matches your current filters.", type = "warning")
      }

      data
    })
  })

  # VALUE BOXES: Unique codes and total activity
  output$unique_codes <- renderText({
    scales::comma(length(unique(filtered_data()$code)))
  })

  output$total_activity <- renderText({
    scales::comma(sum(filtered_data()$usage, na.rm = TRUE))
  })

  # TABLE: Code usage
  output$usage_table <- renderDT({
    filtered_data() |>
      select(-end_date) |>
      datatable_usage()
  })

  # TABLE: Selected codes / Codelist
  output$codes_table <- renderDT({
    selected_codes <- filtered_data() |>
      select(code, description) |>
      distinct()

    datatable_codelist(selected_codes, data_desc = input$dataset)
  })

  # PLOT: Trends over time
  output$usage_plot <- renderPlotly({
    withProgress(message = "Plotting data ...", {
      unique_codes <- length(unique(filtered_data()$code))

      if (input$show_individual_codes & unique_codes <= 500) {
        p <- filtered_data() |>
          plot_individual()
      } else {
        if (input$show_individual_codes & unique_codes >= 500) {
          showNotification(
            "Too many codes to show individually. To show individual code usage reduce to 500 or fewer selected codes.",
            type = "error"
          )
        }

        p <- filtered_data() |>
          group_by(start_date, end_date) |>
          summarise(total_usage = sum(usage, na.rm = TRUE)) |>
          plot_summary()
      }

      ggplotly(p, tooltip = "text") |>
        plotly::config(displayModeBar = FALSE)
    })
  })

  # PLOT: Sparkline overview
  output$sparkline <- renderPlotly({
    data_spark <- filtered_data() |>
      plot_sparkline()
  })
}
