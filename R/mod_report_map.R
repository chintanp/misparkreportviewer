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
tile_layers <- c("streets", "light", "satellite-streets")

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

deletedFeaturesEditId <- NULL

#' @importFrom shiny NS tagList
mod_report_map_ui <- function(id) {
  ns <- NS(id)
  tagList(shinycssloaders::withSpinner(
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
  ))
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
      # print("clearing mapOverlay")
      
      leaflet::leafletProxy(mapId = mapID) %>%
        leaflet::clearGroup(group = removeGroup)
      # print("map cleared")
    }
    
    showReportImagePopup <- function(id, lat, lng) {
      # print(reports_output[[1]]()$mispark_id)
      clearMapOverlay(mapID = "map_reports-map", removeGroup = "infractionImage")
      # if a row is selected - add a UI element to show the image of the selected row
      # id <- reports_output[[1]]()$mispark_id
      # browser()
      if (length(id) > 0 && !is.na(id)) {
        
        # browser()
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
        
        leaflet::leafletProxy(mapId = "map_reports-map") %>%
          leaflet::addPopups(lng = lng,
                             lat = lat,
                             content,
                             group = "infractionImage")
        
      }
    }
    
    output$map_reports <- leaflet::renderLeaflet({
      reports_map
    })
    
    crud <- callModule(
      mapedit::editMod,
      "map_reports",
      editor = "leaflet.extras",
      editorOptions = list(
        polylineOptions = FALSE,
        circleOptions = FALSE,
        markerOptions = FALSE,
        circleMarkerOptions = FALSE,
        editOptions = leaflet.extras::editToolbarOptions(edit = FALSE,),
        singleFeature = TRUE,
        clearFeatures = TRUE
        
      ),
      reports_map
    )
    
    deleted <- isolate(crud()$deleted)
    drawn <- isolate(crud()$drawn)
    
    # lastDeletedFeatureEditID <- reactive({
    #   dplyr::last(selections()$deleted$edit_id)
    # })
    
    # browser()
    
    observeEvent(reports_output[[2]](), {
      # browser()
      # observeEvent(globals$stash$reports, {
      
      req(reports_output[[2]](),
          reports_output[[2]]()$latitude,
          reports_output[[2]]()$longitude)
      clearMapOverlay(mapID = "map_reports-map",
                      removeGroup = "Points")
      clearMapOverlay(mapID = "map_reports-map",
                      removeGroup = "Heatmap")
      
      # browser()
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
          lng = ~longitude,
          lat = ~latitude,
          group = 'Points',
          layerId = reports_output[[2]]()$mispark_id,
          options = leaflet::pathOptions(minZoom = 15),
          radius = 5,
          stroke = FALSE,
          fillOpacity = 0.8,
          color = colorPal(reports_output[[2]]()$severity), 
          data = reports_output[[2]]()
          
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
      showReportImagePopup(
        reports_output[[1]]()$mispark_id,
        reports_output[[1]]()$latitude,
        reports_output[[1]]()$longitude
      )
    })
    
    observeEvent(input[["map_reports-map_marker_click"]], {
      print("map marker click")
      click <- input[["map_reports-map_marker_click"]]
      id <- input[["map_reports-map_marker_click"]]$id
      lat <- input[["map_reports-map_marker_click"]]$lat
      lng <- input[["map_reports-map_marker_click"]]$lng
      print(input[["map_reports-map_marker_click"]]$id)
      # browser()
      # showReportImagePopup(id, lat, lng)
      # Select row needs the row number of the table to select it
      reports_output$selectRow(which(reports_output[[2]]()$mispark_id == id))
    })
    
    observeEvent(crud()$finished, {
      sf_dt_reports <-
        sf::st_as_sf(reports_output[[2]](),
                     coords = c("longitude", "latitude"),
                     crs = 4326)
      
      # str(crud())
      
      req(crud()$finished) # only proceed if not null
      reports_dt_int <-
        sf::st_intersection(crud()$finished, sf_dt_reports)
      
      # str(reports_dt_int)
      # browser()
      req(nrow(reports_dt_int) > 0)
      reports_output$updateTableData(reports_dt_int)
      
      # output$resetMapBtnUI <- renderUI({
      #   print("button should render now")
      #   tags$div(
      #     actionButton(
      #       inputId = ns("resetMapBtn"),
      #       label = "Reset Map and Table",
      #       width = "100%"
      #     ),
      #     tags$br(),
      #     tags$br()
      #   )
      # })
      
      
      # browser()
    })
    
    # observe({
    #   req(selections()$deleted)
    #   deletedLeafletID <-
    #     globals$stash$mcache$get(paste0("deleted", session$token))
    #   print("something deleted")
    #   browser()
    #   if (length(selections()$deleted$X_leaflet_id) == 1 &
    #       is.key_missing(deletedLeafletID)) {
    #     print("delete called")
    #     # clearMapOverlay(mapID = "map_reports-map",
    #     #                 removeGroup = "Points")
    #     # clearMapOverlay(mapID = "map_reports-map",
    #     #                 removeGroup = "Heatmap")
    #     globals$resetReports()
    #     reports_output$resetTable()
    #     # browser()
    #     globals$stash$mcache$set(paste0("deleted", session$token),
    #                              selections()$deleted$X_leaflet_id)
    #     # deletedFeaturesEditId <- selections()$deleted$edit_id
    #     # selections <- NULL
    #
    #   } else if (length(selections()$deleted$X_leaflet_id) > 1 &
    #              deletedLeafletID != dplyr::last(selections()$deleted$X_leaflet_id)) {
    #     print("delete called when length gt 1")
    #     # clearMapOverlay(mapID = "map_reports-map",
    #     #                 removeGroup = "Points")
    #     # clearMapOverlay(mapID = "map_reports-map",
    #     #                 removeGroup = "Heatmap")
    #     globals$resetReports()
    #     reports_output$resetTable()
    #     # browser()
    #     globals$stash$mcache$set(paste0("deleted", session$token),
    #                              dplyr::last(selections()$deleted$edit_id))
    #   }
    #
    # })
    #
    
    
    observeEvent(crud()$deleted, {
      if (!identical(crud()$deleted, deleted)) {
        # print('deleted')
        # str(crud()$deleted)
        deleted <<- crud()$deleted
        globals$resetReports()
        reports_output$resetTable()
        
      }
    })
    
  }

## To be copied in the UI
# mod_report_map_ui("report_map_ui_1")

## To be copied in the server
# callModule(mod_report_map_server, "report_map_ui_1")
