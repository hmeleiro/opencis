\dontshow{httr::set_config(httr::config(ssl_verifypeer = 0L))}
# Use the search_series() function to find a timeserie to import
series <- search_series("presidente preferido")
series
# Use the value in the id column of the search_series() output
df <- read_series(series_code = series$id[1])
dplyr::glimpse(df)
