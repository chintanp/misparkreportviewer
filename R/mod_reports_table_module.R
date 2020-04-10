#' reports_table_module UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_reports_table_module_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(column(
      6,
      bs4Card(
        title = "Misparked Reports",
        closable = FALSE,
        status = "success",
        collapsible = TRUE,
        elevation = 4,
        width = NULL,
        solidHeader = TRUE,
        dataTableOutput(ns("reports_table"))
      )
    ))
  )
}
    
#' reports_table_module Server Function
#'
#' @noRd 
mod_reports_table_module_server <- function(input, output, session, globals){
  ns <- session$ns
  
  output$reports_table = DT::renderDataTable({
    db_conn = globals$stash$conn
    
  })
}
    
## To be copied in the UI
# mod_reports_table_module_ui("reports_table_module_ui_1")
    
## To be copied in the server
# callModule(mod_reports_table_module_server, "reports_table_module_ui_1")
 
