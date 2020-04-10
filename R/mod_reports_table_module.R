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
    db_conn  <- globals$stash$conn
    reports <- DBI::dbGetQuery(db_conn, "select 
                        mr.mispark_id, 
                               mc.company_name,  
                               mt.micromobility_typename,
                               mr.report_datetime, 
                               MAX(it.infraction_severity) as severity,
                               round(cast(ST_X(mr.report_location::geometry) as numeric), 4) as longitude, 
                               round(cast(ST_Y(mr.report_location::geometry) as numeric), 4) as latitude, 
                               mr.report_uid, 
                               mr.report_status 
                               from misparking_report mr
                               JOIN micromobility_services ms
                               ON mr.micromobilityservice_id = ms.micromobilityservice_id
                               JOIN micromobility_type mt 
                               ON mt.micromobilitytype_id = ms.micromobilitytype_id
                               JOIN micromobility_company mc
                               ON mt.company_id = mc.company_id
                               JOIN misparking_report_infraction_xref mx 
                               ON mr.mispark_id = mx.mispark_id
                               JOIN infraction_type it
                               ON mx.infractiontype_id = it.infractiontype_id
                               where mr.micromobilityservice_id IN 
                               (select micromobilityservice_id 
                               from micromobility_city_xref 
                               where city_id = 
                               (select city_id 
                               from city_info 
                               where city = 'Seattle'))
                               GROUP BY mr.mispark_id, mc.company_name, mt.micromobility_typename;
                               ")
  })
}
    
## To be copied in the UI
# mod_reports_table_module_ui("reports_table_module_ui_1")
    
## To be copied in the server
# callModule(mod_reports_table_module_server, "reports_table_module_ui_1")
 
