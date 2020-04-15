#' report_infraction_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_report_infraction_table_ui <- function(id) {
  ns <- NS(id)
  tagList(uiOutput(ns("infractions_output")))
}

#' report_infraction_table Server Function
#'
#' @noRd
mod_report_infraction_table_server <-
  function(input,
           output,
           session,
           globals,
           reports_output) {
    ns <- session$ns
    
    db_conn <- reactive({
      globals$stash$conn
    })
    
    
    observeEvent(reports_output[[1]](),
                 {
                   print(reports_output[[1]]()$mispark_id)
                   # if a row is selected - add a UI element to show the image of the selected row
                   id <- reports_output[[1]]()$mispark_id
                   if (length(id) != 0) {
                     infractionsData <- DBI::dbGetQuery(
                       db_conn(),
                       paste0(
                         "select
                              infraction_description,
                              infraction_severity
                          from infraction_type
                          where infractiontype_id IN
                              (select
                                  infractiontype_id
                              from misparking_report_infraction_xref mx
                              where mx.mispark_id = ",
                              id,
                             ")
                          ORDER BY infraction_severity DESC "
                       )
                     )
                     
                     output$infractions_output <- renderUI({
                       tagList(
                         bs4Dash::bs4Card(
                           title = "Infractions for the selected report",
                           closable = FALSE,
                           status = "success",
                           collapsible = TRUE,
                           elevation = 4,
                           width = NULL,
                           solidHeader = TRUE,
                           DT::DTOutput(ns("infractions_table"))
                           
                         )
                       )
                     })
                     output$infractions_table = DT::renderDT({
                       DT::datatable(
                         infractionsData,
                         selection = "none",
                         filter = 'top',
                         options = list(
                           pageLength = 10,
                           autoWidth = TRUE,
                           scrollX = TRUE,
                           scrollCollapse = TRUE,
                           columnDefs = list(list(
                             className = 'dt-center', targets = "_all"
                           )),
                           initComplete = DT::JS(
                             "function(settings, json) {",
                             "$(this.api().table().header()).css({'background-color': '#EBECEC', 'color': '#000'});",
                             "}"
                           )
                         ),
                         class = 'nowrap display'
                       )
                     })
                   }
                 })
  }

## To be copied in the UI
# mod_report_infraction_table_ui("report_infraction_table_ui_1")

## To be copied in the server
# callModule(mod_report_infraction_table_server, "report_infraction_table_ui_1")
