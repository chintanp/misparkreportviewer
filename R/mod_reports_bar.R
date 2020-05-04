#' reports_bar UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_reports_bar_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
      title = "Severity Bar Chart",
      closable = FALSE,
      status = "success",
      collapsible = TRUE,
      elevation = 4,
      width = NULL,
      solidHeader = TRUE,
      plotly::plotlyOutput(outputId = ns("severity_bar"))
    )
  )
}

#' reports_bar Server Function
#'
#' @noRd
mod_reports_bar_server <- function(input,
                                   output,
                                   session,
                                   globals,
                                   reports_output) {
  ns <- session$ns
  
  output$severity_bar <- plotly::renderPlotly({
    # browser()
    fig <- plotly::plot_ly(reports_output[[2]](), x = ~ as.factor(severity)) %>%
      plotly::add_histogram()
    
    fig <- fig %>% plotly::layout(
      
        xaxis = list(title = "Severity"),
        yaxis = list(title = "Count")

    )
    
    fig
  })
  
}

## To be copied in the UI
# mod_reports_bar_ui("reports_bar_ui_1")

## To be copied in the server
# callModule(mod_reports_bar_server, "reports_bar_ui_1")
