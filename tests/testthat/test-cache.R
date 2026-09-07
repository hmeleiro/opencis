cache_test_response <- function(
  body = "cached body",
  url = "https://www.cis.es/es/estudios/catalogo",
  content_type = "text/html; charset=UTF-8"
) {
  structure(
    list(
      url = url,
      status_code = 200L,
      headers = structure(
        c(
          `content-type` = content_type,
          `set-cookie` = "private=session-cookie"
        ),
        class = c("insensitive", "character")
      ),
      all_headers = list(),
      cookies = data.frame(),
      content = charToRaw(body),
      date = Sys.time(),
      times = numeric(),
      request = list(method = "GET", url = url),
      handle = NULL
    ),
    class = "response"
  )
}

test_that("successful responses persist in the disk cache", {
  cache_dir <- tempfile("opencis-cache-")
  old_options <- options(
    opencis.cache = TRUE,
    opencis.cache_dir = cache_dir,
    opencis.cache_max_age = 3600,
    opencis.cache_max_size = 1024^2
  )
  on.exit({
    opencis:::cis_clear_disk_cache()
    options(old_options)
    opencis:::cis_reset_cache_backend()
  }, add = TRUE)
  opencis:::cis_reset_cache_backend()

  url <- "https://www.cis.es/es/estudios/catalogo?q=test"
  response <- cache_test_response(url = url)

  expect_true(opencis:::cis_cache_set_response(url, response))
  cached <- opencis:::cis_get(url, required = TRUE, context = "testing cache hit")

  expect_s3_class(cached, "response")
  expect_true(isTRUE(attr(cached, "opencis_cache")))
  expect_identical(httr::content(cached, as = "text", encoding = "UTF-8"), "cached body")
  expect_false("set-cookie" %in% tolower(names(httr::headers(cached))))
  expect_identical(opencis::cache_info()$entries, 1L)
})

test_that("cached downloads honor httr write_disk destinations", {
  cache_dir <- tempfile("opencis-cache-")
  old_options <- options(
    opencis.cache = TRUE,
    opencis.cache_dir = cache_dir,
    opencis.cache_max_age = 3600
  )
  on.exit({
    opencis:::cis_clear_disk_cache()
    options(old_options)
    opencis:::cis_reset_cache_backend()
  }, add = TRUE)
  opencis:::cis_reset_cache_backend()

  url <- "https://www.cis.es/documents/1/1/MD1.zip"
  bytes <- as.raw(c(0x50, 0x4b, 0x03, 0x04))
  response <- cache_test_response(
    body = rawToChar(bytes),
    url = url,
    content_type = "application/zip"
  )
  response$content <- bytes
  expect_true(opencis:::cis_cache_set_response(url, response))

  destination <- tempfile(fileext = ".zip")
  cached <- opencis:::cis_get(
    url,
    httr::write_disk(destination, overwrite = TRUE),
    required = TRUE,
    context = "testing cached download"
  )

  expect_identical(readBin(destination, "raw", n = file.info(destination)$size), bytes)
  expect_identical(cached$content, destination)
})

test_that("anti-bot pages and HTTP errors are never cached", {
  cache_dir <- tempfile("opencis-cache-")
  old_options <- options(
    opencis.cache = TRUE,
    opencis.cache_dir = cache_dir,
    opencis.cache_max_age = 3600
  )
  on.exit({
    opencis:::cis_clear_disk_cache()
    options(old_options)
    opencis:::cis_reset_cache_backend()
  }, add = TRUE)
  opencis:::cis_reset_cache_backend()

  url <- "https://www.cis.es/es/estudios/catalogo"
  challenge <- cache_test_response(
    paste0(
      '<form action="/__cis_antibot">',
      '<input name="challenge" value=""></form>'
    ),
    url = url
  )
  expect_false(opencis:::cis_cache_set_response(url, challenge))

  failed <- cache_test_response("server error", url = url)
  failed$status_code <- 500L
  expect_false(opencis:::cis_cache_set_response(url, failed))
  expect_null(opencis:::cis_cache_get_response(url))
})

test_that("cache can be disabled and cleared explicitly", {
  cache_dir <- tempfile("opencis-cache-")
  old_options <- options(
    opencis.cache = TRUE,
    opencis.cache_dir = cache_dir,
    opencis.cache_max_age = 3600
  )
  on.exit({
    opencis:::cis_clear_disk_cache()
    options(old_options)
    opencis:::cis_reset_cache_backend()
  }, add = TRUE)
  opencis:::cis_reset_cache_backend()

  url <- "https://www.cis.es/es/estudios/catalogo"
  expect_true(opencis:::cis_cache_set_response(url, cache_test_response(url = url)))
  opencis::clear_cache()
  expect_null(opencis:::cis_cache_get_response(url))

  options(opencis.cache = FALSE)
  expect_false(opencis::cache_info()$enabled)
  expect_false(opencis:::cis_cache_set_response(url, cache_test_response(url = url)))
})
