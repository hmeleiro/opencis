\dontshow{if(Sys.info()["sysname"] == "Linux") httr::set_config(httr::config(ssl_verifypeer = 0L))}
# Search by search terms
questions <- search_questions(search_terms = "feminismo")
print(questions)

# Narrow the search by dates
questions <- search_questions(search_terms = "feminismo", since_date = "01-01-2010")
print(questions)
