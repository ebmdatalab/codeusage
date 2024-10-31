server <- function(input, output, session) {
  
  icd10_usage <- codeusage::icd10_usage
  snomed_usage <- codeusage::snomed_usage
  
  # Reactive expression for the selected dataset
  selected_data <- reactive({
    if (input$dataset == "snomed") {
      snomed_usage %>%
        select(start_date, code = snomed_concept_id, description, usage)
    } else if (input$dataset == "icd10") {
      icd10_usage %>%
        select(start_date, code = icd10_code, description, usage)
    }
  })
  
  # Update selectizeInput choices
  observe({
    updateSelectizeInput(
      session, "code_search",
      choices = unique(selected_data()$code),
      server = TRUE)
  })
  
  # Filtered data
  filtered_data <- reactive({
    data <- selected_data()
    
    if (!is.null(input$code_search) && length(input$code_search) > 0) {
      data <- data %>% filter(code %in% input$code_search)
    }
    
    if (!is.null(input$description_search) && input$description_search != "") {
      data <- data %>% filter(grepl(input$description_search, description, ignore.case = TRUE))
    }

    observeEvent(input$load_codelist, {
    if (!is.null(input$codelist_url) && input$codelist_url != "") {

      selected_codes <- codeusage::get_opencodelist(input$codelist_url) |> 
        pull(code)

      data <- data %>% filter(code %in% selected_codes)
    }
  })
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
    filtered_data() %>%
      select(code, description) %>%
      distinct() %>%
      datatable(
        colnames = c("Code", "Description"),
        rownames = FALSE,
        options = list(
          columnDefs = list(
            list(width = '50px', targets = 0),
            list(width = '500px', targets = 1)
          ),
          pageLength = 10,
          scrollX = TRUE,
          searching = FALSE
        )
      )
  })
  
  # Code usage trends over time
  output$usage_plot <- renderPlotly({
    
    scale_x_date_breaks <- unique(filtered_data()$start_date)
    unique_codes <- length(unique(filtered_data()$code))
    
    if (input$show_individual_codes & unique_codes <= 500) {
      
      p <- filtered_data() %>%
        ggplot(
          aes(
            x = start_date,
            y = usage,
            colour = code)
        ) +
        geom_line(alpha = .4) +
        geom_point(
          size = 2,
          aes(text = paste0(
            "<b>Month:</b> ",
            lubridate::month(start_date, label = TRUE), " ",
            lubridate::year(start_date), "<br>",
            "<b>Code:</b> ", code, "<br>",
            "<b>Description:</b> ", description, "<br>",
            "<b>Usage:</b> ", scales::comma(usage))
          )
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
          legend.position="none"
        )
      
    } else {
      
      p <- filtered_data() %>%
        group_by(start_date) %>%
        summarise(total_usage = sum(usage, na.rm = TRUE)) %>%
        ggplot(
          aes(x = start_date, y = total_usage)
        ) +
        geom_line(
          colour = "#239b89ff",
          alpha = .4) +
        geom_point(
          colour = "#239b89ff",
          size = 2,
          aes(text = paste0(
            "<b>Month:</b> ",
            lubridate::month(start_date, label = TRUE), " ",
            lubridate::year(start_date), "<br>",
            "<b>Usage:</b> ", scales::comma(total_usage))
          )
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
  
  # Code usage table
  output$usage_table <- renderDT({
    filtered_data() %>%
      datatable(
        colnames = c("Date", "Code", "Description", "Usage"),
        rownames = FALSE,
        options = list(
          columnDefs = list(
            list(width = '60px', targets = 0),
            list(width = '80px', targets = 1),
            list(width = '350px', targets = 2),
            list(width = '60px', targets = 3)
          ),
          pageLength = 10,
          scrollX = TRUE,
          searching = FALSE
        )
      )
  })
  
  # Sparkline overview
  output$sparkline <- renderPlotly({
    
    data_spark <- filtered_data() %>%
      group_by(start_date) %>%
      summarise(total_usage = sum(usage, na.rm = TRUE))
    
    plot_ly(data_spark, hoverinfo = "none") %>%
      add_lines(
        x = ~start_date, y = ~total_usage,
        color = I("black"), span = I(1),
        fill = 'tozeroy', alpha = 0.2
      ) %>%
      layout(
        xaxis = list(visible = F, showgrid = F, title = ""),
        yaxis = list(visible = F, showgrid = F, title = ""),
        hovermode = "x",
        margin = list(t = 0, r = 0, l = 0, b = 0),
        font = list(color = "white"),
        paper_bgcolor = "transparent",
        plot_bgcolor = "transparent"
      ) %>%
      config(displayModeBar = FALSE)
  })
  
}