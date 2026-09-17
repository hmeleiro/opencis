retry_response <- function(status = 429L, retry_after = NULL) {
  headers <- c(`content-type` = "text/plain", `retry-after` = retry_after)
  structure(list(
    status_code = status, content = charToRaw("response"),
    headers = structure(headers, class = c("insensitive", "character"))
  ), class = "response")
}

test_that("Retry-After accepts seconds and HTTP dates", {
  now <- as.POSIXct("2026-09-17 12:00:00", tz = "GMT")
  expect_equal(opencis:::cis_retry_after(retry_response(retry_after = "120")), 120)
  expect_equal(opencis:::cis_retry_after(
    retry_response(retry_after = "Thu, 17 Sep 2026 12:02:00 GMT"), now
  ), 120)
  expect_equal(opencis:::cis_retry_after(
    retry_response(retry_after = "Thu, 17 Sep 2026 11:59:00 GMT"), now
  ), 0)
  expect_null(opencis:::cis_retry_after(retry_response()))
  expect_null(opencis:::cis_retry_after(retry_response(retry_after = "invalid")))
})

test_that("429 retries preserve the request and respect Retry-After", {
  calls <- 0L
  sleeps <- numeric()
  old <- options(opencis.cache = FALSE, opencis.request_interval = 0)
  on.exit(options(old))
  local_mocked_bindings(
    cis_perform_get = function(url, session, ...) {
      expect_identical(url, "https://www.cis.es/test")
      calls <<- calls + 1L
      retry_response(if (calls == 1L) 429L else 200L, "120")
    },
    cis_http_sleep = function(seconds) sleeps <<- c(sleeps, seconds),
    .package = "opencis"
  )
  result <- suppressMessages(opencis:::cis_get("https://www.cis.es/test"))
  expect_equal(httr::status_code(result), 200L)
  expect_equal(calls, 2L)
  expect_equal(sleeps, 120)
})

test_that("retries stop and preserve required versus optional failure behavior", {
  calls <- 0L
  sleeps <- numeric()
  old <- options(opencis.cache = FALSE, opencis.request_interval = 0,
                 opencis.max_retries = 2)
  on.exit(options(old))
  local_mocked_bindings(
    cis_perform_get = function(...) {
      calls <<- calls + 1L
      retry_response()
    },
    cis_http_sleep = function(seconds) sleeps <<- c(sleeps, seconds),
    .package = "opencis"
  )
  expect_warning(result <- suppressMessages(opencis:::cis_get("https://www.cis.es/test")), "HTTP 429")
  expect_null(result)
  expect_equal(calls, 3L)
  expect_true(sleeps[1] >= 1 && sleeps[1] <= 2)
  expect_true(sleeps[2] >= 2 && sleeps[2] <= 4)
  options(opencis.max_retries = 0)
  expect_error(opencis:::cis_get("https://www.cis.es/test", required = TRUE), "HTTP 429")
  expect_equal(calls, 4L)
})

test_that("other HTTP errors are not retried", {
  calls <- 0L
  old <- options(opencis.request_interval = 0)
  on.exit(options(old))
  local_mocked_bindings(cis_perform_get = function(...) {
    calls <<- calls + 1L
    retry_response(404L)
  }, .package = "opencis")
  expect_equal(httr::status_code(opencis:::cis_get_with_retry(
    "https://www.cis.es/test", NULL
  )), 404L)
  expect_equal(calls, 1L)
})

test_that("throttling is per origin and session reset clears it", {
  sleeps <- numeric()
  old <- options(opencis.request_interval = 10)
  on.exit({options(old); opencis:::cis_reset_http_sessions()})
  opencis:::cis_reset_http_sessions()
  local_mocked_bindings(cis_http_sleep = function(seconds) {
    sleeps <<- c(sleeps, seconds)
  }, .package = "opencis")
  opencis:::cis_throttle("https://www.cis.es/one")
  opencis:::cis_throttle("https://www.cis.es/two")
  opencis:::cis_throttle("https://example.org/one")
  expect_length(sleeps, 1L)
  expect_true(sleeps[1] > 0 && sleeps[1] <= 10)
  opencis:::cis_reset_http_sessions()
  opencis:::cis_throttle("https://www.cis.es/three")
  expect_length(sleeps, 1L)
})

test_that("pagination distinguishes failures from empty pages and can resume", {
  pages <- numeric()
  failed <- TRUE
  local_mocked_bindings(search_cis = function(start, ...) {
    pages <<- c(pages, start)
    if (start == 2 && failed) return(NULL)
    if (start == 3) return(tibble::tibble())
    tibble::tibble(study = as.character(start))
  }, .package = "opencis")
  expect_warning(partial <- search_all_cis(), "Incomplete CIS search: page 2")
  expect_equal(partial$study, "1")
  expect_false(attr(partial, "complete"))
  expect_equal(attr(partial, "next_page"), 2)
  expect_equal(pages, c(1, 2))
  failed <- FALSE
  rest <- search_all_cis(start = attr(partial, "next_page"))
  expect_equal(rest$study, "2")
  expect_true(attr(rest, "complete"))
  expect_null(attr(rest, "next_page"))
  expect_equal(pages, c(1, 2, 2, 3))
  expect_error(search_all_cis(start = 0), "positive integer")
})

test_that("failed single-page searches are not memoised", {
  calls <- 0L
  local_mocked_bindings(
    cis_get = function(...) {
      calls <<- calls + 1L
      if (calls == 1L) NULL else retry_response(200L)
    },
    parse_study = function(...) tibble::tibble(study = "1234"),
    .package = "opencis"
  )
  expect_null(search_cis(q = "retry"))
  expect_equal(search_cis(q = "retry")$study, "1234")
  expect_equal(calls, 2L)
})

test_that("empty catalogs are complete but first-page failures are not", {
  local_mocked_bindings(search_cis = function(...) NULL, .package = "opencis")
  expect_warning(result <- search_all_cis(), "Incomplete CIS search: page 1")
  expect_equal(nrow(result), 0)
  expect_false(attr(result, "complete"))
  expect_equal(attr(result, "next_page"), 1)
  local_mocked_bindings(search_cis = function(...) tibble::tibble(), .package = "opencis")
  result <- search_all_cis()
  expect_equal(nrow(result), 0)
  expect_true(attr(result, "complete"))
})

test_that("GET after anti-bot verification also retries 429", {
  calls <- 0L
  verified <- FALSE
  old <- options(opencis.cache = FALSE, opencis.request_interval = 0)
  on.exit(options(old))
  local_mocked_bindings(
    cis_perform_get = function(...) {
      calls <<- calls + 1L
      retry_response(if (calls == 2L) 429L else 200L)
    },
    cis_is_antibot_challenge = function(...) calls == 1L,
    cis_complete_antibot = function(...) verified <<- TRUE,
    cis_http_sleep = function(...) NULL,
    .package = "opencis"
  )
  result <- suppressMessages(opencis:::cis_get("https://www.cis.es/test", required = TRUE))
  expect_true(verified)
  expect_equal(calls, 3L)
  expect_equal(httr::status_code(result), 200L)
})
