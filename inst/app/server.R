plot_total_code_usage <- function(data) {
  scale_x_date_breaks <- unique(data$start_date)

  ggplot2::ggplot(data, aes(x = start_date, y = total_usage)) +
    ggplot2::geom_line(
      colour = "#239b89ff",
      alpha = .4
    ) +
    ggplot2::geom_point(
      colour = "#239b89ff",
      size = 2,
      ggplot2::aes(text = paste0(
        "<b>Month:</b> ",
        lubridate::month(start_date, label = TRUE), " ",
        lubridate::year(start_date), "<br>",
        "<b>Usage:</b> ", scales::comma(total_usage)
      ))
    ) +
    ggplot2::scale_x_date(
      breaks = scale_x_date_breaks,
      labels = scales::label_date_short()
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, NA),
      labels = scales::label_comma()
    ) +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_classic() +
    ggplot2::theme(text = ggplot2::element_text(size = 14))
}

plot_individual_code_usage <- function(data) {
  scale_x_date_breaks <- unique(data$start_date)

  ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = start_date,
      y = usage,
      colour = code
    )
  ) +
    ggplot2::geom_line(alpha = .4) +
    ggplot2::geom_point(
      size = 2,
      ggplot2::aes(text = paste0(
        "<b>Month:</b> ",
        lubridate::month(start_date, label = TRUE), " ",
        lubridate::year(start_date), "<br>",
        "<b>Code:</b> ", code, "<br>",
        "<b>Description:</b> ", description, "<br>",
        "<b>Usage:</b> ", scales::comma(usage)
      ))
    ) +
    ggplot2::scale_x_date(
      breaks = scale_x_date_breaks,
      labels = scales::label_date_short()
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, NA),
      labels = scales::label_comma()
    ) +
    ggplot2::scale_colour_viridis_d() +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      text = ggplot2::element_text(size = 14),
      legend.position = "none"
    )
}

server <- function(input, output, session) {
  icd10_usage <- codeusage::icd10_usage
  snomed_usage <- codeusage::snomed_usage

  # Reactive expression for the selected dataset
  selected_data <- reactive({
    if (input$dataset == "snomed") {
      snomed_usage |>
        select(start_date, code = snomed_concept_id, description, usage)
    } else if (input$dataset == "icd10") {
      icd10_usage |>
        select(start_date, code = icd10_code, description, usage)
    }
  })

  # Update selectizeInput choices
  observe({
    updateSelectizeInput(
      session, "code_search",
      choices = unique(selected_data()$code),
      server = TRUE
    )
  })
  
  selected_codelist <- observeEvent(input$load_codelist, {
    req(input$codelist_url)
    tryCatch({
      codeusage::get_opencodelist(input$codelist_url)
    }, error = function(e) {
      showNotification("Error loading codelist. Please check the URL.", type = "error")
    })
  })

  # Filtered data
  filtered_data <- reactive({
    data <- selected_data()

    if (!is.null(input$code_search) && length(input$code_search) > 0) {
      data <- data |> filter(code %in% input$code_search)
    }

    if (!is.null(input$description_search) && input$description_search != "") {
      data <- data |> filter(grepl(input$description_search, description, ignore.case = TRUE))
    }

    data
  })

  # Value boxes
  output$unique_codes <- renderText({
    scales::comma(length(unique(filtered_data()$code)))
  })

  output$total_activity <- renderText({
    scales::comma(sum(filtered_data()$usage, na.rm = TRUE))
  })

  # Selected codes table
  output$codes_table <- renderDT({
    
    # filtered_data() |>
    #   select(code, description) |>
    #   distinct() |>
    selected_codelist() |> 
      datatable(
        colnames = c("Code", "Description"),
        rownames = FALSE,
        options = list(
          columnDefs = list(
            list(width = "50px", targets = 0),
            list(width = "500px", targets = 1)
          ),
          pageLength = 10,
          scrollX = TRUE,
          searching = FALSE
        )
      )
  })

  # Code usage trends over time
  output$usage_plot <- renderPlotly({
    unique_codes <- length(unique(filtered_data()$code))

    if (input$show_individual_codes & unique_codes <= 500) {
      p <- filtered_data() |>
        plot_individual_code_usage()
    } else {
      p <- filtered_data() |>
        group_by(start_date) |>
        summarise(total_usage = sum(usage, na.rm = TRUE)) |>
        plot_total_code_usage()
    }

    ggplotly(p, tooltip = "text") |> 
      plotly::config(displayModeBar = FALSE)
  })

  # Code usage table
  output$usage_table <- renderDT({
    filtered_data() |> 
      datatable(
        colnames = c("Date", "Code", "Description", "Usage"),
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

  # Sparkline overview
  output$sparkline <- renderPlotly({
    data_spark <- filtered_data() |> 
      group_by(start_date) |> 
      summarise(total_usage = sum(usage, na.rm = TRUE))

    plot_ly(data_spark, hoverinfo = "none") |> 
      add_lines(
        x = ~start_date, y = ~total_usage,
        color = I("black"), span = I(1),
        fill = "tozeroy", alpha = 0.2
      ) |> 
      layout(
        xaxis = list(visible = F, showgrid = F, title = ""),
        yaxis = list(visible = F, showgrid = F, title = ""),
        hovermode = "x",
        margin = list(t = 0, r = 0, l = 0, b = 0),
        font = list(color = "white"),
        paper_bgcolor = "transparent",
        plot_bgcolor = "transparent"
      ) |> 
      config(displayModeBar = FALSE)
  })
}
