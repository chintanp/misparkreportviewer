GlobalModule <- function(input, output, session) {
  stash = reactiveValues()
  #####################
  # Database connection
  #####################
  conn <- pool::dbPool(
    drv = RPostgres::Postgres(),
    dbname = Sys.getenv("SLIMEBIKE_DB"),
    host = Sys.getenv("SLIMEBIKE_HOST"),
    user = Sys.getenv("SLIMEBIKE_USER"),
    password = Sys.getenv("SLIMEBIKE_PWD"),
    port = Sys.getenv("SLIMEBIKE_PORT")
  )
  stash$conn <- conn
  
  ##redis
  # r <- redux::hiredis()
  # r$DEL("deletedFeaturesEditId") 
  # stash$r <- r
  
  ## MemoryCache
  mcache <- shiny::memoryCache()
  stash$mcache <- mcache
  
  get_all_reports <- function() {
    reports <- DBI::dbGetQuery(
      conn,
      "select
             mr.mispark_id,
              string_agg(distinct mc.company_name, ', ') as company_name,
             string_agg(distinct mt.micromobility_typename, ', ') as type,
             mr.report_datetime,
             MAX(it.infraction_severity) as severity,
             round(cast(ST_X(mr.report_location::geometry) as numeric), 4) as longitude,
             round(cast(ST_Y(mr.report_location::geometry) as numeric), 4) as latitude,
             mr.report_uid,
             ci.city
         from misparking_report mr
         JOIN micromobility_services ms
          ON ms.micromobilityservice_id =  ANY(mr.micromobilityservice_ids)
         JOIN micromobility_type mt
          ON mt.micromobilitytype_id = ms.micromobilitytype_id
         JOIN micromobility_company mc
          ON mt.company_id = mc.company_id
         JOIN misparking_report_infraction_xref mx
          ON mr.mispark_id = mx.mispark_id
         JOIN infraction_type it
          ON mx.infractiontype_id = it.infractiontype_id
         JOIN city_info ci
          ON mr.city_id = ci.city_id
         GROUP BY mr.mispark_id, ci.city
		 ORDER BY mr.mispark_id;
         "
    )
    
    return (reports)
  }
   
  reports <- get_all_reports()
  
  stash$reports <- reports
  
  stash$sf_reports <- sf::st_as_sf(reports, coords = c("longitude", "latitude"), crs = 4326)
  
  return (list(stash = stash, 
               updateReports = function(reps) {
                 # print("updating reports")
                 # print(str(reps))
                 stash$reports <- reps
               }, 
               resetReports = function() {
                 # print("reseting reports to the full list")
                 reports <- get_all_reports()
                 
                 stash$reports <- reports
               }))
}