#' report_image UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_report_image_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' report_image Server Function
#'
#' @noRd 
mod_report_image_server <- function(input, output, session, globals){
  ns <- session$ns
 
}
    
## To be copied in the UI
# mod_report_image_ui("report_image_ui_1")
    
## To be copied in the server
# callModule(mod_report_image_server, "report_image_ui_1")
 
