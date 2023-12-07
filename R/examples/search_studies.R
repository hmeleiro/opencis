\dontshow{if(Sys.info()["sysname"] == "Linux") httr::set_config(httr::config(ssl_verifypeer = 0L))}
# Search by search terms
studies <- search_studies(search_terms = "postelectoral")
print(studies)

# Narrow the search by dates
studies <- search_studies(search_terms = "postelectoral",
                          since_date = "01-01-2011",
                          until_date = "01-01-2020")
print(studies)

# Use the scope_code parameter to search only national studies
studies <- search_studies(search_terms = "postelectoral",
                          since_date = "01-01-2011",
                          until_date = "01-01-2020",
                          scope_code = "001")
print(studies)
