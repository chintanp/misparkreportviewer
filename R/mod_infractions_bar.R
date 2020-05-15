#' infractions_bar UI Function
#'
#' @description A shiny Module to plot a bar chart of infraction types 
#' that is sensitive to data table updates.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_infractions_bar_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shinycssloaders::withSpinner(plotly::plotlyOutput(outputId = ns("infraction_bar"))
  ))
}

#' infractions_bar Server Function
#'
#' @noRd
mod_infractions_bar_server <- function(input,
                                       output,
                                       session,
                                       globals,
                                       reports_output) {
  ns <- session$ns
  
  db_conn <- reactive({
    globals$stash$conn
  })
  
  output$infraction_bar <- plotly::renderPlotly({
    # browser()
    #if(length(reports_output[[2]]()$mispark_id) != 0) {
      req(reports_output[[2]]())
      req(reports_output[[2]]()$mispark_id)
      # Get the infraction descriptions for the mispark_ids in the table
      infractionData <- DBI::dbGetQuery(
        db_conn(),
        paste0(
          "select it.infraction_description, count(mrix.infractiontype_id)
          	from misparking_report_infraction_xref mrix
          	JOIN infraction_type it
          	ON it.infractiontype_id = mrix.infractiontype_id
          	where mrix.mispark_id IN (",
          paste(reports_output[[2]]()$mispark_id, collapse = ", "),
          ") group by (it.infraction_description)"
        )
      )
      
      req(infractionData)
      fig <-
        plotly::plot_ly(
          infractionData,
          x = ~ infraction_description,
          y = ~ count,
          type = "bar"
        ) %>%
        plotly::layout(xaxis = list(title = "Infraction Types"),
                       yaxis = list(title = "Count"))
      
      fig
    # }

  })
}

## To be copied in the UI
# mod_infractions_bar_ui("infractions_bar_ui_1")

## To be copied in the server
# callModule(mod_infractions_bar_server, "infractions_bar_ui_1")
