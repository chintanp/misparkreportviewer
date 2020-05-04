#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  
  GlobalData = callModule(GlobalModule, "globals")
  
  # List the first level callModules here
  reports_output <- callModule(mod_reports_table_module_server, "reports_table_module_ui_1", GlobalData)
  callModule(mod_report_map_server, "report_map_ui_1", GlobalData, reports_output)
  # callModule(mod_report_image_server, "report_image_ui_1", GlobalData, reports_output)
  callModule(mod_report_infraction_table_server, "report_infraction_table_ui_1", GlobalData, reports_output)
  callModule(mod_reports_bar_server, "reports_bar_ui_1", GlobalData, reports_output)
  callModule(mod_infractions_bar_server, "infractions_bar_ui_1", GlobalData, reports_output)
}
