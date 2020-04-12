#' report_image UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_report_image_ui <- function(id) {
  ns <- NS(id)
  tagList(uiOutput(ns("image_output")))
  
}

#' report_image Server Function
#'
#' @noRd
mod_report_image_server <-
  function(input,
           output,
           session,
           globals,
           reports_output) {
    ns <- session$ns
    
    db_conn <- reactive({
      globals$stash$conn
    })
    

    observeEvent(reports_output(), {
      print(reports_output()$mispark_id)
      # if a row is selected - add a UI element to show the image of the selected row
      id <- reports_output()$mispark_id
      if (length(id) != 0) {
        imageData <- DBI::dbGetQuery(db_conn(),
                                     paste0("select report_image from misparking_report where mispark_id = ", id))
        
        output$image_output <- renderUI({
          tagList(fluidRow(column(
            6,
            bs4Dash::bs4Card(
              title = "Infraction Image",
              closable = FALSE,
              status = "success",
              collapsible = TRUE,
              elevation = 4,
              width = NULL,
              solidHeader = TRUE,
              maximizable = TRUE,
              tags$img(src = paste0("data:image/png;base64, ", imageData$report_image))
            )
          )))
        })
      }
    })
  }

## To be copied in the UI
# mod_report_image_ui("report_image_ui_1")

## To be copied in the server
# callModule(mod_report_image_server, "report_image_ui_1")
