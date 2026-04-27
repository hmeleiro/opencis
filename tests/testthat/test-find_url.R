test_that("find_url extracts matching CIS ZIP links", {
    html <- paste(
        '<a href="https://www.cis.es/documents/3411/3411/MD3411.zip">zip</a>',
        '<a href="https://www.cis.es/documents/3328/3328/MD3328.zip">zip2</a>'
    )

    out <- opencis:::find_url(html)
    expect_length(out, 2)
    expect_true(all(grepl("^https://www.cis.es/documents/", out)))

    out_one <- opencis:::find_url(html, ids = c("3411", "3411"))
    expect_identical(out_one, "https://www.cis.es/documents/3411/3411/MD3411.zip")
})
