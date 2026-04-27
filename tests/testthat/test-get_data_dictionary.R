test_that("get_data_dictionary returns expected structure", {
    x <- structure(c(1, 2), label = "Sexo", labels = c(Hombre = 1, Mujer = 2))
    y <- c("A", "B")
    df <- data.frame(SEXO = x, LETRA = y)

    dict <- opencis::get_data_dictionary(df)

    expect_s3_class(dict, "tbl_df")
    expect_equal(nrow(dict), 2)
    expect_equal(dict$variable, c("SEXO", "LETRA"))
    expect_equal(dict$label[[1]], "Sexo")
    expect_true(is.na(dict$label[[2]]))
})
