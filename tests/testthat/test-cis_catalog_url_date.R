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
