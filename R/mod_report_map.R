#' report_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#'
# Module globals
tile_layers <- c("light", "streets", "satellite-streets")

colorPal <-
  leaflet::colorNumeric("inferno", domain = c(0, 10), reverse = TRUE)

reports_map <- leaflet::leaflet() %>%
  leaflet::fitBounds(-171.791110603, 18.91619,-66.96466, 71.3577635769) %>%
  leaflet.mapboxgl::addMapboxGL(
    style = "mapbox://styles/mapbox/satellite-streets-v11",
    group = tile_layers[3],
    setView = FALSE,
    accessToken = "pk.eyJ1IjoiY2hpbnRhbnAiLCJhIjoiY2ppYXU1anVuMThqazNwcDB2cGtneDdkYyJ9.TL6RTyRRFCbvJWyFa4P0Ow"
  ) %>%
  leaflet.mapboxgl::addMapboxGL(
    style = "mapbox://styles/mapbox/streets-v11",
    group = tile_layers[2],
    setView = FALSE,
    accessToken = "pk.eyJ1IjoiY2hpbnRhbnAiLCJhIjoiY2ppYXU1anVuMThqazNwcDB2cGtneDdkYyJ9.TL6RTyRRFCbvJWyFa4P0Ow"
  ) %>%
  leaflet.mapboxgl::addMapboxGL(
    style = "mapbox://styles/mapbox/light-v10",
    group = tile_layers[1],
    setView = FALSE,
    accessToken = "pk.eyJ1IjoiY2hpbnRhbnAiLCJhIjoiY2ppYXU1anVuMThqazNwcDB2cGtneDdkYyJ9.TL6RTyRRFCbvJWyFa4P0Ow"
  ) %>%
  # addPolylines(data = wa_roads, opacity = 1, weight = 2) %>%
  leaflet.extras::addResetMapButton() %>% 
  leafem::addMouseCoordinates()

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
        mapedit::editModUI(
          id = ns("map_reports"),
          height = 600,
          width = "100%"
        ),
        # leaflet::leafletOutput(
        #   outputId = ns("map_reports"),
        #   height = 700,
        #   width = "100%"
        # ),
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
    
    clearMapOverlay <- function(mapID, removeGroup) {
      print("clearing mapOverlay")
      
      leaflet::leafletProxy(mapId = mapID) %>%
        leaflet::clearGroup(group = removeGroup)
    }
    
    output$map_reports <- leaflet::renderLeaflet({
      reports_map
    })
    
    selections <- callModule(
      mapedit::editMod,
      "map_reports",
      editor = "leafpm",
      editorOptions = list(
        toolbarOptions = leafpm::pmToolbarOptions(drawMarker = FALSE,
                                                  drawPolyline = FALSE)
      ),
      reports_map
    )
    
    
    # browser()
    
    observeEvent(reports_output[[2]](), {
      # browser()
      # observeEvent(globals$stash$reports, {
      
      clearMapOverlay(mapID = "map_reports-map",
                      removeGroup = "Points")
      clearMapOverlay(mapID = "map_reports-map",
                      removeGroup = "Heatmap")
      
      
      # output$map_reports <- leaflet::renderLeaflet({
      leaflet::leafletProxy("map_reports-map") %>% # the id is inspired from this comment https://github.com/r-spatial/mapedit/issues/95#issuecomment-481888386
        leaflet.extras::addHeatmap(
          lng = reports_output[[2]]()$longitude,
          lat = reports_output[[2]]()$latitude,
          blur = 20,
          max = 0.05,
          radius = 15,
          group = 'Heatmap'
        ) %>%
        leaflet::addCircleMarkers(
          lng = reports_output[[2]]()$longitude,
          lat = reports_output[[2]]()$latitude,
          group = 'Points',
          options = leaflet::pathOptions(minZoom = 15),
          radius = 5,
          stroke = FALSE,
          fillOpacity = 0.8,
          color = colorPal(reports_output[[2]]()$severity)
          
        ) %>%
        leaflet::addLayersControl(
          baseGroups = tile_layers,
          overlayGroups = c("Heatmap", "Points"),
          options = leaflet::layersControlOptions(collapsed = FALSE)
        ) %>%
        leaflet::removeControl("severity_legend") %>%
        leaflet::addLegend(
          "bottomright",
          pal = colorPal,
          values = reports_output[[2]]()$severity,
          title = "Severity",
          opacity = 0.6,
          group = "Points",
          layerId = "severity_legend"
        )
      
      #      })
      
      # browser()

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
        
        clearMapOverlay(mapID = "map_reports-map", removeGroup = "infractionImage")
        leaflet::leafletProxy(mapId = "map_reports-map") %>%
          leaflet::addPopups(
            lng = reports_output[[1]]()$longitude,
            lat = reports_output[[1]]()$latitude,
            content,
            group = "infractionImage"
          )
        
      }
    })
    
    observe({
      
      sf_dt_reports <- sf::st_as_sf(reports_output[[2]](), coords = c("longitude", "latitude"), crs = 4326)
      
      str(selections())
      
      req(selections()$finished) # only proceed if not null
      reports_dt_int <- sf::st_intersection(selections()$finished, sf_dt_reports)
      
      str(reports_dt_int)
      # browser()
    })
  }

## To be copied in the UI
# mod_report_map_ui("report_map_ui_1")

## To be copied in the server
# callModule(mod_report_map_server, "report_map_ui_1")
