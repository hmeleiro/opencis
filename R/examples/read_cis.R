\dontshow{if(Sys.info()["sysname"] == "Linux") httr::set_config(httr::config(ssl_verifypeer = 0L))}
# If you know the study code you can just read it into R
df <- read_cis("3328")
print(df)

# If you dont know the study code, you can search for a study using search_studies() function:
studies <- search_studies(search_terms = "gastronomia")
print(studies)

df <- read_cis(studies$codigo[1])
print(df)
