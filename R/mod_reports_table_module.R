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
 
  )
}
    
#' reports_table_module Server Function
#'
#' @noRd 
mod_reports_table_module_server <- function(input, output, session){
  ns <- session$ns
 
}
    
## To be copied in the UI
# mod_reports_table_module_ui("reports_table_module_ui_1")
    
## To be copied in the server
# callModule(mod_reports_table_module_server, "reports_table_module_ui_1")
 
