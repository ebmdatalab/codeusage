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
    if (input$dataset == "snomed") {
      codeusage::snomed_usage %>%
        select(start_date, end_date, code = snomed_concept_id, description, usage)
    } else if (input$dataset == "icd10") {
      codeusage::icd10_usage %>%
        select(start_date, end_date, code = icd10_code, description, usage)
    } else if (input$dataset == "opcs") {
      codeusage::opcs_usage %>%
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

    tryCatch(
      {
        codelist_s7 <- get_codelist(input$codelist_slug)
        codelist_df <- codelist_s7 |>
          tibble::as_tibble() |>
          dplyr::select(1:2)

        codelist_df
      },
      error = function(e) {
        showNotification("Error loading Codelist.", type = "error")
      }
    )
  }) |>
    bindEvent(input$load_codelist, ignoreNULL = FALSE)

  # DATA: Filtered usage data
  filtered_data <- reactive({
    data <- selected_data()

    if (!is.null(input$code_search) && length(input$code_search) > 0) {
      data <- data %>% filter(code %in% input$code_search)
    }

    if (!is.null(input$description_search) && input$description_search != "") {
      data <- data %>% filter(grepl(input$description_search, description, ignore.case = TRUE))
    }

    if (!is.null(input$codelist_slug) && input$codelist_slug != "") {
      data <- data %>% filter(code %in% selected_codelist()$code)
    }

    data
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
    filtered_data() %>%
      select(-end_date) %>%
      datatable(
        colnames = c("Start date", "Code", "Description", "Usage"),
        rownames = FALSE,
        options = list(
          columnDefs = list(
            list(width = "60px", targets = 0),
            list(width = "80px", targets = 1),
            list(width = "350px", targets = 2),
            list(width = "60px", targets = 3)
          ),
          pageLength = 10,
          scrollX = TRUE,
          searching = FALSE
        )
      )
  })

  # TABLE: Selected codes
  output$codes_table <- renderDT({
    filtered_data() %>%
      select(code, description) %>%
      distinct() %>%
      datatable(
        colnames = c("Code", "Description"),
        rownames = FALSE,
        extensions = c("Buttons", "Scroller"),
        options = list(
          columnDefs = list(
            list(width = "50px", targets = 0),
            list(width = "500px", targets = 1)
          ),
          pageLength = 20,
          scrollX = TRUE,
          searching = FALSE,
          dom = "Bfrtip",
          buttons = list(
            "copy",
            list(
              extend = "csv",
              title = paste0("selected_", input$dataset, "_codes")
            )
          ),
          deferRender = TRUE,
          scrollY = 400,
          scroller = TRUE
        )
      )
  })

  # PLOT: Trends over time
  output$usage_plot <- renderPlotly({
    scale_x_date_breaks <- unique(filtered_data()$start_date)
    unique_codes <- length(unique(filtered_data()$code))

    if (input$show_individual_codes & unique_codes <= 500) {
      p <- filtered_data() %>%
        ggplot(
          aes(
            x = start_date,
            y = usage,
            colour = code
          )
        ) +
        geom_line(alpha = .4) +
        geom_point(
          size = 2,
          aes(text = paste0(
            "<b>Timeframe:</b> ",
            lubridate::month(start_date, label = TRUE), " ",
            lubridate::year(start_date), " to ",
            lubridate::month(end_date, label = TRUE), " ",
            lubridate::year(end_date),
            "<br>",
            "<b>Code:</b> ", code, "<br>",
            "<b>Description:</b> ", description, "<br>",
            "<b>Code usage:</b> ", scales::comma(usage)
          ))
        ) +
        scale_x_date(
          breaks = scale_x_date_breaks,
          labels = scales::label_date_short()
        ) +
        scale_y_continuous(
          limits = c(0, NA),
          labels = scales::label_comma()
        ) +
        ggplot2::scale_colour_viridis_d() +
        labs(x = NULL, y = NULL) +
        theme_classic() +
        theme(
          text = element_text(size = 14),
          legend.position = "none"
        )
    } else {
      p <- filtered_data() %>%
        group_by(start_date, end_date) %>%
        summarise(total_usage = sum(usage, na.rm = TRUE)) %>%
        ggplot(
          aes(x = start_date, y = total_usage)
        ) +
        geom_line(
          colour = "#239b89ff",
          alpha = .4
        ) +
        geom_point(
          colour = "#239b89ff",
          size = 2,
          aes(text = paste0(
            "<b>Timeframe:</b> ",
            lubridate::month(start_date, label = TRUE), " ",
            lubridate::year(start_date), " to ",
            lubridate::month(end_date, label = TRUE), " ",
            lubridate::year(end_date),
            "<br>",
            "<b>Code usage:</b> ", scales::comma(total_usage)
          ))
        ) +
        scale_x_date(
          breaks = scale_x_date_breaks,
          labels = scales::label_date_short()
        ) +
        scale_y_continuous(
          limits = c(0, NA),
          labels = scales::label_comma()
        ) +
        labs(x = NULL, y = NULL) +
        theme_classic() +
        theme(text = element_text(size = 14))
    }

    ggplotly(p, tooltip = "text") %>%
      plotly::config(displayModeBar = FALSE)
  })

  # PLOT: Sparkline overview
  output$sparkline <- renderPlotly({
    data_spark <- filtered_data() %>%
      group_by(start_date) %>%
      summarise(total_usage = sum(usage, na.rm = TRUE))

    plotly::plot_ly(data_spark, hoverinfo = "none") %>%
      plotly::add_lines(
        x = ~start_date, y = ~total_usage,
        color = I("black"), span = I(1),
        fill = "tozeroy", alpha = 0.2
      ) %>%
      plotly::layout(
        xaxis = list(visible = F, showgrid = F, title = ""),
        yaxis = list(visible = F, showgrid = F, title = ""),
        hovermode = "x",
        margin = list(t = 0, r = 0, l = 0, b = 0),
        font = list(color = "white"),
        paper_bgcolor = "transparent",
        plot_bgcolor = "transparent"
      ) %>%
      plotly::config(displayModeBar = FALSE) |>
      layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE))
  })
}
