#' reports_table_module UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_reports_table_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
      title = "Misparked Reports",
      closable = FALSE,
      status = "success",
      collapsible = TRUE,
      elevation = 4,
      width = NULL,
      maximizable = TRUE,
      solidHeader = TRUE,
      DT::DTOutput(ns("reports_table"))
    )
  )
}

#' reports_table_module Server Function
#'
#' @noRd
mod_reports_table_module_server <-
  function(input, output, session, globals) {
    ns <- session$ns
    
    output$reports_table = DT::renderDT({
      DT::datatable(
        globals$stash$reports,
        selection = "single",
        filter = 'top',
        options = list(
          pageLength = 10,
          autoWidth = TRUE,
          scrollX = TRUE,
          scrollCollapse = TRUE,
          columnDefs = list(list(
            className = 'dt-center', targets = "_all"
          )),
          dom = 'Bfrtip',
          # buttons = c('colvis'),
          
          initComplete = DT::JS(
            "function(settings, json) {",
            "$(this.api().table().header()).css({'background-color': '#EBECEC', 'color': '#000'});",
            "}"
          )
        ),
        class = 'nowrap display',
        extensions = c('Buttons')
      )
    })
    
    # return the selected row, so other modules can use it to update relevant views
    return(reactive({
      id <- input$reports_table_rows_selected
      globals$stash$reports[id,]
    }))
    
  }

## To be copied in the UI
# mod_reports_table_module_ui("reports_table_module_ui_1")

## To be copied in the server
# callModule(mod_reports_table_module_server, "reports_table_module_ui_1")
