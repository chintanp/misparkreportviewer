#' report_infraction_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_report_infraction_table_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' report_infraction_table Server Function
#'
#' @noRd 
mod_report_infraction_table_server <- function(input, output, session, globals){
  ns <- session$ns
 
}
    
## To be copied in the UI
# mod_report_infraction_table_ui("report_infraction_table_ui_1")
    
## To be copied in the server
# callModule(mod_report_infraction_table_server, "report_infraction_table_ui_1")
 
