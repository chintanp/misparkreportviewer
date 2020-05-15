#' info_page UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_info_page_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
      closable = FALSE,
      collapsible = FALSE,
      elevation = 0,
      width = NULL,
      tags$div(
        tags$h4("Information about the Misparked Reports Viewer"),
        tags$br(),
        tags$br(),
        tags$p(
          " The misparked reports viewer shows the reports collected through the ",
          tags$a(href = "https://misplacedwheels.com/", "Misplaced Wheels App.")
        ),
        tags$br(),
        tags$br(),
        tags$p(
          " The Misparked Reports table allows filtering of reports to particular city or date-time window etc. The filter updates the reports on the map and associated charts. The complete set or the filtered set can be downloaded into various formats for further analysis. A row click displays the image submitted with the report as a popup on the map as well as a table  of the associated infractions. "
        ),
        imageOutput(ns("tableUseImage")),
        tags$br(),
        tags$br(),
        tags$p(
          " Another mode of down-selecting the reports is by drawing a rectangle or a polygon around the area of interest on the map. The Misparked Reports table updates to show the selected reports and the charts update to show the relevant summary statistics. The points on the map can be clicked to the display the submitted image. "
        ),
        imageOutput(ns("mapUseImage"))
      )
      
    )
  )
}

#' info_page Server Function
#'
#' @noRd
mod_info_page_server <- function(input, output, session) {
  ns <- session$ns
  output$tableUseImage <- renderImage({
    # Return a list containing the filename
    list(
      src = "./inst/app/www/filtering_table.gif",
      contentType = 'image/gif',
      alt = "GIF video showing how to use the filters on the table and the associated effects."
    )
  }, deleteFile = FALSE)
  
  output$mapUseImage <- renderImage({
    # Return a list containing the filename
    list(
      src = "./inst/app/www/map_selection.gif",
      contentType = 'image/gif',
      alt = "GIF video showing the method of map selection and associated effects. "
    )
  }, deleteFile = FALSE)

}

## To be copied in the UI
# mod_info_page_ui("info_page_ui_1")

## To be copied in the server
# callModule(mod_info_page_server, "info_page_ui_1")
