#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  home_tab <- bs4Dash::bs4TabItem(tabName = "home_tab",
                                  fluidRow(
                                    column(
                                      3,
                                      mod_reports_table_module_ui("reports_table_module_ui_1")
                                    ),
                                    column(
                                      9,
                                      
                                      bs4Dash::bs4TabCard(
                                        title = tags$p(
                                          "Map and Charts",
                                          style = " font-size: 20px;
                                                    font-weight: 600; 
                                                    margin: 0; "
                                        ),
                                        elevation = 4,
                                        id = "map_charts_tabcard",
                                        width = 12,
                                        collapsible = TRUE,
                                        maximizable = TRUE,
                                        closable = FALSE,
                                        type = "tabs",
                                        status = "purple",
                                        solidHeader = FALSE,
                                        bs4Dash::bs4TabPanel(
                                          tabName = "Map",
                                          active = TRUE,
                                          mod_report_map_ui("report_map_ui_1")
                                        ),
                                        bs4Dash::bs4TabPanel(tabName = "Infraction Type Bar Chart",
                                                             mod_infractions_bar_ui("infractions_bar_ui_1")),
                                        bs4Dash::bs4TabPanel(tabName = "Severity Bar Chart",
                                                             mod_reports_bar_ui("reports_bar_ui_1"))
                                      )
                                    )
                                  ),
                                  fluidRow(column(
                                    6,
                                    mod_report_infraction_table_ui("report_infraction_table_ui_1")
                                  )))
  
  info_tab <- bs4Dash::bs4TabItem(tabName = "info_tab",
                                  fluidRow(
                                    column(
                                      width = 12,
                                      mod_info_page_ui("info_page_ui_1"),
                                      class = "text-left"
                                    )))
  
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here
    bs4Dash::bs4DashPage(
      enable_preloader = FALSE,
      navbar = bs4Dash::bs4DashNavbar(
        skin = "light",
        status = "white",
        border = TRUE,
        sidebarIcon = "bars",
        controlbarIcon = "th",
        fixed = FALSE
      ),
      sidebar = bs4Dash::bs4DashSidebar(
        skin = "light",
        status = "purple",
        title = "Misparked Repo",
        brandColor = "purple",
        url = "",
        src = 'https://upload.wikimedia.org/wikipedia/commons/e/e9/Arabesque-letter-m-icon.png',
        elevation = 3,
        opacity = 0.3,
        bs4Dash::bs4SidebarMenu(
          bs4Dash::bs4SidebarHeader(""),
          bs4Dash::bs4SidebarMenuItem("Home",
                                      tabName = "home_tab",
                                      icon = "home"),
          bs4Dash::bs4SidebarMenuItem("Info",
                                      tabName = "info_tab",
                                      icon = "info-circle")
        )
      ),
      controlbar = bs4Dash::bs4DashControlbar(disable = TRUE),
      footer = bs4Dash::bs4DashFooter(
        copyrights = a(
          href = "",
          target = "_blank",
          "Sustainable Transportation Lab, UW,
             Chintan Pathak, Borna Arabkhedri, Don MacKenzie"
        ),
        right_text = "2020"
      ),
      title = "test",
      body = bs4Dash::bs4DashBody(shinyjs::useShinyjs(),
                                  bs4Dash::bs4TabItems(home_tab, 
                                                       info_tab))
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path('www', app_sys('app/www'))
  
  tags$head(favicon(),
            bundle_resources(path = app_sys('app/www'),
                             app_title = 'misparkreportviewer'))
  # Add here other external resources
  # for example, you can add shinyalert::useShinyalert() )
}
