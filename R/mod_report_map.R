#' report_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_report_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
      title = "Map of Reports",
      closable = FALSE,
      status = "success",
      collapsible = TRUE,
      elevation = 4,
      width = NULL,
      solidHeader = TRUE,
      maximizable = TRUE,
      shinycssloaders::withSpinner(
      leaflet::leafletOutput(outputId = ns("map_reports"), height = 700, width = "100%"),
      type = 8,
      color = "#0dc5c1"
      )
    )
  )
}

#' report_map Server Function
#'
#' @noRd
mod_report_map_server <-
  function(input,
           output,
           session,
           globals,
           reports_output) {
    ns <- session$ns
    
    db_conn <- reactive({
      globals$stash$conn
    })
    
    clearMapOverlay <- function(mapID) {
      print("clearing markers now")
      leaflet::leafletProxy(mapId = mapID) %>%
        leaflet::clearGroup(group = "infractionImage")
    }
    
    tile_layers <- c("light", "streets", "satellite-streets")
    
    # browser()
    
    observeEvent(reports_output[[2]](), {
      # browser()
      
      output$map_reports <- leaflet::renderLeaflet({
        leaflet::leaflet() %>%
          leaflet::fitBounds(-171.791110603, 18.91619,-66.96466, 71.3577635769) %>%
          leaflet.mapboxgl::addMapboxGL(style = "mapbox://styles/mapbox/satellite-streets-v11",
                                        group = tile_layers[3],
                                        setView = FALSE) %>%
          # addPolylines(data = wa_roads, opacity = 1, weight = 2) %>%
          leaflet.extras::addResetMapButton() %>%
          # leaflet.extras::addSearchOSM() %>%
          leaflet.extras::addHeatmap(
            lng = reports_output[[2]]()$longitude,
            lat = reports_output[[2]]()$latitude,
            blur = 20,
            max = 0.05,
            radius = 15, 
            group = 'Heatmap'
          ) %>%
          leaflet::addCircleMarkers(lng = reports_output[[2]]()$longitude,
                                    lat = reports_output[[2]]()$latitude, 
                                    group = 'Points',
                                    options = leaflet::pathOptions(
                                      minZoom = 15
                                    )
                                    
          ) %>%
          leaflet::addLayersControl(
            overlayGroups = c("Heatmap", "Points"),
            options = leaflet::layersControlOptions(collapsed = FALSE)
          )
      })
    })
    
    observeEvent(reports_output[[1]](), {
      print(reports_output[[1]]()$mispark_id)
      # if a row is selected - add a UI element to show the image of the selected row
      id <- reports_output[[1]]()$mispark_id
      if (length(id) != 0) {
        imageData <- DBI::dbGetQuery(
          db_conn(),
          paste0(
            "select report_image from misparking_report where mispark_id = ",
            id
          )
        )
        
        content  <-
          paste0(
            '<img style="border:10px outset silver;" width="150" alt="Photo of Infraction" src="data:image/png;base64, ',
            imageData$report_image,
            '"/>
            '
          )
        
        clearMapOverlay(mapID = "map_reports")
        leaflet::leafletProxy(mapId = "map_reports") %>%
          leaflet::addPopups(
            lng = reports_output[[1]]()$longitude,
            lat = reports_output[[1]]()$latitude,
            content,
            group = "infractionImage"
          )
        
      }
    })
  }

## To be copied in the UI
# mod_report_map_ui("report_map_ui_1")

## To be copied in the server
# callModule(mod_report_map_server, "report_map_ui_1")
