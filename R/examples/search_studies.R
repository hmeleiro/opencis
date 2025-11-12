\dontshow{httr::set_config(httr::config(ssl_verifypeer = 0L))}
# Search by search terms
studies <- search_studies(q = "postelectoral")
print(studies)

# Narrow the search by dates
studies <- search_studies(q = "postelectoral",
                          from = "2011-01-01",
                          to = "2020-01-01")
print(studies)

# Use the catalogo parameter to search for questions ("pregunta") or data series ("serie")
studies <- search_studies(q = "ideologia",
                          from = "2011-01-01",
                          to = "2020-01-01",
                          catalogo = "serie")
print(studies)
