challenge_html <- function(seed = "w5BA6i12dWjkvcdK2QAx", prefix = "0000") {
  paste0(
    '<!doctype html><html><head><title>Bot Detection</title></head><body>',
    '<form method="POST" action="/__cis_antibot" id="form">',
    '<input type="hidden" name="challenge" id="challenge" value="">',
    '<input type="hidden" name="next" value="/es/estudios/catalogo">',
    '</form><script>',
    'a = 0; while (!SHA256("', seed, '" + a).startsWith("', prefix, '")) { a++; }',
    'document.getElementById("challenge").value = a.toString();',
    'document.getElementById("form").submit();',
    '</script></body></html>'
  )
}

fake_response <- function(html, url = "https://www.cis.es/es/estudios/catalogo") {
  structure(
    list(
      url = url,
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
      request = list(method = "GET", url = url),
      handle = NULL
    ),
    class = "response"
  )
}

test_that("anti-bot page is detected and parsed", {
  response <- fake_response(challenge_html())

  expect_true(opencis:::cis_is_antibot_challenge(response))
  challenge <- opencis:::cis_parse_antibot_challenge(response)

  expect_identical(challenge$action, "https://www.cis.es/__cis_antibot")
  expect_identical(challenge$fields[["next"]], "/es/estudios/catalogo")
  expect_identical(challenge$seed, "w5BA6i12dWjkvcdK2QAx")
  expect_identical(challenge$prefix, "0000")
})

test_that("proof of work reproduces the captured CIS challenge", {
  solution <- opencis:::cis_solve_antibot_pow(
    "w5BA6i12dWjkvcdK2QAx",
    "0000",
    max_attempts = 200000
  )

  expect_identical(solution, 112463)
  hash <- digest::digest(
    paste0("w5BA6i12dWjkvcdK2QAx", solution),
    algo = "sha256",
    serialize = FALSE
  )
  expect_true(startsWith(hash, "0000"))
})

test_that("proof of work stops at the configured safety limit", {
  expect_error(
    opencis:::cis_solve_antibot_pow("seed", "ffffffff", max_attempts = 2),
    "Could not solve"
  )
})

test_that("challenge parser keeps additional hidden fields", {
  html <- sub(
    '<input type="hidden" name="challenge"',
    '<input type="hidden" name="token" value="server-state"><input type="hidden" name="challenge"',
    challenge_html(),
    fixed = TRUE
  )
  challenge <- opencis:::cis_parse_antibot_challenge(fake_response(html))

  expect_identical(challenge$fields$token, "server-state")
})

test_that("substring-style difficulty checks are parsed", {
  html <- sub(
    '!SHA256("w5BA6i12dWjkvcdK2QAx" + a).startsWith("0000")',
    'SHA256("w5BA6i12dWjkvcdK2QAx" + a).substring(0, 5) !== "00000"',
    challenge_html(),
    fixed = TRUE
  )
  challenge <- opencis:::cis_parse_antibot_challenge(fake_response(html))

  expect_identical(challenge$prefix, "00000")
})

test_that("relative challenge actions are resolved against the request URL", {
  expect_identical(
    opencis:::cis_absolute_url("__cis_antibot", "https://www.cis.es/es/catalogo"),
    "https://www.cis.es/es/__cis_antibot"
  )
})

test_that("HTTP session keeps the cookie handle and user agent stable", {
  opencis:::cis_reset_http_sessions()
  on.exit(opencis:::cis_reset_http_sessions(), add = TRUE)

  first <- opencis:::cis_http_session("https://www.cis.es/es/estudios/catalogo")
  second <- opencis:::cis_http_session("https://www.cis.es/otra-ruta")

  expect_identical(first$handle, second$handle)
  expect_identical(first$user_agent, second$user_agent)

  opencis:::cis_reset_http_sessions()
  fresh <- opencis:::cis_http_session("https://www.cis.es/es/estudios/catalogo")
  expect_false(identical(first$handle, fresh$handle))
})

test_that("challenge submission is restricted to the original site", {
  html <- sub(
    'action="/__cis_antibot"',
    'action="https://example.org/__cis_antibot"',
    challenge_html(),
    fixed = TRUE
  )

  expect_error(
    opencis:::cis_parse_antibot_challenge(fake_response(html)),
    "different origin"
  )
})

test_that("ordinary HTML is not treated as an anti-bot page", {
  response <- fake_response("<html><title>CIS catalog</title><body>Studies</body></html>")
  expect_false(opencis:::cis_is_antibot_challenge(response))
})
