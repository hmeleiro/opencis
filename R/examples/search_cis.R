if (interactive()) {
# Search by search terms
studies <- search_cis(q = "postelectoral")
print(studies)

# Narrow the search by dates
studies <- search_cis(q = "postelectoral",
                          from = "2011-01-01",
                          to = "2020-01-01")
print(studies)

# Use the catalogo parameter to search for questions ("pregunta") or data series ("serie")
studies <- search_cis(q = "ideologia",
                          from = "2011-01-01",
                          to = "2020-01-01",
                          catalogo = "serie")
print(studies)

# Advanced Lucene searches start with an asterisk
studies <- search_cis(q = "*surveyCode:(2610 OR 2829 OR 2956)")
print(studies)

questions <- search_cis(
  q = "*question_es_ES:(divorcio)",
  catalogo = "pregunta"
)
print(questions)
}
