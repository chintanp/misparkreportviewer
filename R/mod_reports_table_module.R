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
      status = "purple",
      collapsible = TRUE,
      elevation = 4,
      width = NULL,
      maximizable = TRUE,
      solidHeader = TRUE,
      DT::DTOutput(ns("reports_table"), height = 600)
    )
  )
}

#' reports_table_module Server Function
#'
#' @noRd
mod_reports_table_module_server <-
  function(input, output, session, globals) {
    ns <- session$ns
    
    proxy = DT::dataTableProxy('reports_table')
    
    makeTable <- function() {
      # print("making table")
      output$reports_table = DT::renderDT({
        # print("OG DF")
        # print(str(globals$stash$reports))
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
      }, server = TRUE)
    }
    
    makeTable()
    # return the selected row, so other modules can use it to update relevant views
    return(list(
      reactive({
        id <- input$reports_table_rows_selected
        globals$stash$reports[id,]
      }),
      reactive({
        # browser()
        # req(input$reports_table_rows_all)
        if (!is.null(input$reports_table_rows_all)) {
          ids <- input$reports_table_rows_all
          globals$stash$reports[ids,] %>% tidyr::drop_na(mispark_id)
        } else if (!is.null(globals$stash$reports)) {
          globals$stash$reports %>% tidyr::drop_na(mispark_id)
        }
        
      }),
      
      updateTableData = function(newData) {
        # print("updateData called")
        # print(str(newData))
        # browser()
        #format the data returned from mapEdit to something the datatable is used to
        drops <- c("X_leaflet_id", "layerId", "edit_id", "feature_type")
        newData <- newData[, !(names(newData) %in% drops)]
        newData <-
          newData %>% dplyr::mutate(longitude = unlist(purrr::map(newData$geometry, 1)),
                                    latitude = unlist(purrr::map(newData$geometry, 2)))
        newData <- newData %>% sf::st_drop_geometry()
        
        observe({
          DT::replaceData(proxy, newData)
        })
        
        globals$updateReports(newData)
      },
      
      resetTable = function() {
        makeTable()
      }
    ))
    
  }

## To be copied in the UI
# mod_reports_table_module_ui("reports_table_module_ui_1")

## To be copied in the server
# callModule(mod_reports_table_module_server, "reports_table_module_ui_1")
