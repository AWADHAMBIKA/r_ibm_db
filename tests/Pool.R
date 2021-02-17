library(DBI)
library(pool)
  pool <- dbPool(
    drv = RIBMDB::ODBC(),
    dbname = "dbtest",
    host = "abc@abc.com",
    port = 60000,
    user = "admin",
    password = "admin"
  )
  dbGetQuery(pool, "SELECT * from dummy;")
  poolClose(pool)