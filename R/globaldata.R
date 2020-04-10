GlobalModule <- function(input, output, session) {
  stash = reactiveValues()
  #####################
  # Database connection
  #####################
    stash$conn <- pool::dbPool(
      drv = RPostgres::Postgres(),
      dbname = Sys.getenv("SLIMEBIKE_DB"),
      host = Sys.getenv("SLIMEBIKE_HOST"),
      user = Sys.getenv("SLIMEBIKE_USER"),
      password = Sys.getenv("SLIMEBIKE_PWD"), 
      port = Sys.getenv("SLIMEBIKE_PORT")
    )

  return (
    list(stash = stash)
  )
}