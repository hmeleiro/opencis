test_that("cis_catalog_url_date builds URL with expected query params", {
    url <- opencis:::cis_catalog_url_date(
        start = 2,
        q = "postelectoral",
        from = "2020-01-01",
        to = "2020-12-31",
        sort = "publishDate-",
        catalogo = "estudio"
    )

    expect_match(url, "start=2")
    expect_match(url, "q=postelectoral")
    expect_match(url, "fromDate=2020-01-01")
    expect_match(url, "toDate=2020-12-31")
    expect_match(url, "catalogo=estudio")
})

test_that("cis_catalog_url_date preserves advanced Lucene queries", {
    queries <- c(
        "*title_es_ES:(+barometro +2024 -sanitario)",
        "*surveyCode:(2610 OR 2829 OR 2956)",
        "*(surveyCodeNumber:[3000 TO 3002])",
        "*question_es_ES:(divorcio)",
        "*question_es_ES:(divorcio) AND surveyCodeNumber:{3540 TO *]",
        '*title_es_ES:"barometro de la vivienda"'
    )

    for (query in queries) {
        url <- opencis:::cis_catalog_url_date(q = query)
        decoded_query <- httr::parse_url(url)$query$q

        expect_identical(decoded_query, query)
    }
})
