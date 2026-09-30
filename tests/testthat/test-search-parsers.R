search_parser_response <- function(card_html) {
  html <- paste0(
    '<html><body><div class="card-content">',
    '<a title="Result title" href="/result/1">Result</a>',
    '<ul class="card-info">', card_html, '</ul>',
    '</div></body></html>'
  )

  structure(
    list(
      url = "https://www.cis.es/es/estudios/catalogo",
      status_code = 200L,
      headers = structure(
        c(`content-type` = "text/html; charset=UTF-8"),
        class = c("insensitive", "character")
      ),
      all_headers = list(),
      cookies = data.frame(),
      content = charToRaw(html),
      date = Sys.time(),
      times = numeric(),
      request = list(method = "GET"),
      handle = NULL
    ),
    class = "response"
  )
}

test_that("question results use the current CIS metadata order", {
  response <- search_parser_response(paste0(
    "<li>Pregunta 42</li>",
    "<li>15/09/2026</li>"
  ))

  result <- opencis:::parse_question(response)

  expect_identical(result$question, "42")
  expect_identical(result$date, as.Date("2026-09-15"))
  expect_identical(result$title, "Result title")
  expect_identical(result$url, "/result/1")
})

test_that("series results parse dates and data point counts in order", {
  response <- search_parser_response(paste0(
    "<li>Serie 123</li>",
    "<li>01/02/2020</li>",
    "<li>30/09/2026</li>",
    "<li>Puntos 81</li>"
  ))

  result <- opencis:::parse_serie(response)

  expect_identical(result$serie, "123")
  expect_identical(result$from, as.Date("2020-02-01"))
  expect_identical(result$to, as.Date("2026-09-30"))
  expect_identical(result$data_points, 81)
  expect_identical(result$title, "Result title")
  expect_identical(result$url, "/result/1")
})
