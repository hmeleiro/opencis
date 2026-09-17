.opencis_http_state <- new.env(parent = emptyenv())
.opencis_http_state$sessions <- new.env(parent = emptyenv())
.opencis_http_state$last_request <- new.env(parent = emptyenv())

cis_http_option <- function(name, default) {
  value <- getOption(name, default)
  if (!is.numeric(value) || length(value) != 1 || !is.finite(value) || value < 0) {
    return(default)
  }
  value
}

cis_http_sleep <- function(seconds) Sys.sleep(seconds)

cis_throttle <- function(url) {
  origin <- cis_url_origin(url)
  interval <- cis_http_option("opencis.request_interval", 1)
  last <- .opencis_http_state$last_request[[origin]]
  now <- unname(proc.time()[["elapsed"]])
  if (!is.null(last)) {
    delay <- interval - (now - last)
    if (delay > 0) cis_http_sleep(delay)
  }
  .opencis_http_state$last_request[[origin]] <- unname(proc.time()[["elapsed"]])
}

cis_retry_after <- function(resp, now = Sys.time()) {
  headers <- as.list(httr::headers(resp))
  names(headers) <- tolower(names(headers))
  value <- headers[["retry-after"]]
  if (is.null(value) || length(value) != 1 || is.na(value)) return(NULL)
  value <- trimws(value)
  if (grepl("^[0-9]+$", value)) {
    seconds <- suppressWarnings(as.numeric(value))
  } else {
    date <- tryCatch(httr::parse_http_date(value), error = function(e) NA)
    seconds <- as.numeric(difftime(date, now, units = "secs"))
  }
  if (length(seconds) != 1 || !is.finite(seconds)) return(NULL)
  max(0, seconds)
}

cis_get_with_retry <- function(url, session, ...) {
  retries <- floor(cis_http_option("opencis.max_retries", 5))
  attempt <- 0
  repeat {
    cis_throttle(url)
    resp <- cis_perform_get(url, session, ...)
    if (httr::status_code(resp) != 429 || attempt >= retries) return(resp)
    delay <- cis_retry_after(resp)
    if (is.null(delay)) {
      # Exponential backoff with jitter, capped at 60 seconds.
      cap <- min(60, 2^(attempt + 1))
      delay <- stats::runif(1, cap / 2, cap)
    }
    delay <- max(1, delay)
    attempt <- attempt + 1
    message(sprintf("HTTP 429. Retrying in %.1f seconds (%s/%s).", delay, attempt, retries))
    cis_http_sleep(delay)
  }
}

cis_request_timeout <- function() {
  timeout <- getOption("opencis.timeout", 20)
  timeout <- suppressWarnings(as.numeric(timeout))
  if (length(timeout) != 1 || is.na(timeout) || timeout <= 0) {
    return(20)
  }
  timeout
}

cis_antibot_max_attempts <- function() {
  max_attempts <- getOption("opencis.antibot.max_attempts", 5000000)
  max_attempts <- suppressWarnings(as.numeric(max_attempts))
  if (length(max_attempts) != 1 || is.na(max_attempts) || max_attempts < 1) {
    return(5000000)
  }
  floor(max_attempts)
}

cis_user_agent <- function() {
  user_agents <- c(
    # Chrome - Windows
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36",

    # Chrome - macOS
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36",

    # Firefox - Windows
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:142.0) Gecko/20100101 Firefox/142.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:141.0) Gecko/20100101 Firefox/141.0",

    # Firefox - macOS
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:142.0) Gecko/20100101 Firefox/142.0",

    # Edge
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0",

    # Safari - macOS
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15"
  )

  sample(user_agents, 1)
}

cis_url_origin <- function(url) {
  parsed <- httr::parse_url(url)
  if (is.null(parsed$scheme) || is.null(parsed$hostname)) {
    stop("Expected an absolute HTTP(S) URL.", call. = FALSE)
  }

  default_port <- is.null(parsed$port) ||
    (identical(parsed$scheme, "https") && identical(parsed$port, "443")) ||
    (identical(parsed$scheme, "http") && identical(parsed$port, "80"))
  port <- if (default_port) "" else paste0(":", parsed$port)

  paste0(tolower(parsed$scheme), "://", tolower(parsed$hostname), port)
}

cis_absolute_url <- function(url, base_url) {
  if (grepl("^https?://", url, ignore.case = TRUE)) {
    return(url)
  }
  if (startsWith(url, "//")) {
    return(paste0(httr::parse_url(base_url)$scheme, ":", url))
  }
  if (startsWith(url, "/")) {
    return(paste0(cis_url_origin(base_url), url))
  }

  parsed <- httr::parse_url(base_url)
  path <- parsed$path
  if (is.null(path) || !nzchar(path)) {
    path <- "/"
  }
  directory <- sub("[^/]*$", "", path)
  if (!startsWith(directory, "/")) {
    directory <- paste0("/", directory)
  }
  paste0(cis_url_origin(base_url), directory, url)
}

cis_same_origin <- function(url, other_url) {
  identical(cis_url_origin(url), cis_url_origin(other_url))
}

cis_http_session <- function(url) {
  origin <- cis_url_origin(url)
  sessions <- .opencis_http_state$sessions

  if (!exists(origin, envir = sessions, inherits = FALSE)) {
    assign(
      origin,
      list(
        handle = httr::handle(origin),
        user_agent = cis_user_agent()
      ),
      envir = sessions
    )
  }

  get(origin, envir = sessions, inherits = FALSE)
}

cis_reset_http_sessions <- function() {
  sessions <- .opencis_http_state$sessions
  rm(list = ls(envir = sessions, all.names = TRUE), envir = sessions)
  .opencis_http_state$last_request <- new.env(parent = emptyenv())
  invisible(NULL)
}

cis_response_text <- function(resp) {
  tryCatch(
    httr::content(resp, as = "text", encoding = "UTF-8"),
    error = function(e) ""
  )
}

cis_is_antibot_challenge <- function(resp) {
  content_type <- httr::headers(resp)[["content-type"]]
  if (!is.null(content_type) && !grepl("html", content_type, ignore.case = TRUE)) {
    return(FALSE)
  }

  html <- cis_response_text(resp)
  if (!nzchar(html)) {
    return(FALSE)
  }

  has_endpoint <- grepl("/__cis_antibot(?:[?'\"#[:space:]]|$)", html, perl = TRUE)
  has_challenge_field <- grepl(
    "<input[^>]+name\\s*=\\s*['\"]challenge['\"]",
    html,
    ignore.case = TRUE,
    perl = TRUE
  )

  has_endpoint && has_challenge_field
}

cis_regex_capture <- function(pattern, text, group = 1L) {
  match <- regexec(pattern, text, perl = TRUE, ignore.case = TRUE)
  captures <- regmatches(text, match)[[1]]
  if (length(captures) <= group) {
    return(NULL)
  }
  captures[[group + 1L]]
}

cis_extract_pow_seed <- function(script) {
  patterns <- c(
    # SHA256("seed" + counter)
    "(?:sha256|sha_256)\\s*\\(\\s*['\"]([^'\"]+)['\"]\\s*\\+\\s*[A-Za-z_$][A-Za-z0-9_$]*\\s*\\)",
    # "seed" + counter, kept as a fallback for minor JS refactors
    "['\"]([A-Za-z0-9_-]{8,128})['\"]\\s*\\+\\s*(?:a|i|counter|nonce)\\b",
    # const seed/nonce/salt = "..."
    "(?:seed|nonce|salt)\\s*=\\s*['\"]([^'\"]+)['\"]"
  )

  for (pattern in patterns) {
    seed <- cis_regex_capture(pattern, script)
    if (!is.null(seed) && nzchar(seed)) {
      return(seed)
    }
  }
  NULL
}

cis_extract_pow_prefix <- function(script) {
  patterns <- c(
    "(?:startsWith|starts_with)\\s*\\(\\s*['\"](0+)['\"]\\s*\\)",
    "(?:substring|substr|slice)\\s*\\([^)]*\\)\\s*(?:={2,3}|!={1,2})\\s*['\"](0+)['\"]",
    "['\"](0{2,12})['\"]\\s*(?:={2,3}|!={1,2})"
  )

  for (pattern in patterns) {
    prefix <- cis_regex_capture(pattern, script)
    if (!is.null(prefix) && nzchar(prefix)) {
      return(prefix)
    }
  }

  fallback <- getOption("opencis.antibot.prefix", "0000")
  if (!is.character(fallback) || length(fallback) != 1 || !grepl("^0+$", fallback)) {
    stop(
      "Could not determine the CIS proof-of-work difficulty from the challenge page.",
      call. = FALSE
    )
  }
  fallback
}

cis_parse_antibot_challenge <- function(resp, request_url = resp$url) {
  html <- cis_response_text(resp)
  document <- tryCatch(rvest::read_html(html), error = function(e) NULL)
  if (is.null(document)) {
    stop("Could not parse the CIS anti-bot challenge page.", call. = FALSE)
  }

  forms <- rvest::html_elements(document, "form")
  actions <- rvest::html_attr(forms, "action")
  selected <- which(
    !is.na(actions) & grepl("/__cis_antibot(?:[?#].*)?$", actions, perl = TRUE)
  )
  if (length(selected) == 0) {
    stop("The CIS anti-bot form was not found on the challenge page.", call. = FALSE)
  }

  form <- forms[[selected[[1]]]]
  action <- cis_absolute_url(actions[[selected[[1]]]], request_url)
  if (!cis_same_origin(action, request_url)) {
    stop("Refusing to submit the CIS challenge to a different origin.", call. = FALSE)
  }

  inputs <- rvest::html_elements(form, "input[name]")
  input_names <- rvest::html_attr(inputs, "name")
  input_values <- rvest::html_attr(inputs, "value")
  input_values[is.na(input_values)] <- ""
  fields <- as.list(input_values)
  names(fields) <- input_names
  fields <- fields[!is.na(names(fields)) & nzchar(names(fields))]

  if (!"challenge" %in% names(fields)) {
    fields$challenge <- ""
  }
  if (!"next" %in% names(fields) || !nzchar(fields[["next"]])) {
    origin <- cis_url_origin(request_url)
    next_url <- substring(request_url, nchar(origin) + 1L)
    fields[["next"]] <- if (startsWith(next_url, "/")) next_url else paste0("/", next_url)
  }

  script_nodes <- rvest::html_elements(document, "script")
  script <- paste(rvest::html_text(script_nodes), collapse = "\n")
  seed <- cis_extract_pow_seed(script)
  if (is.null(seed)) {
    stop("Could not extract the proof-of-work seed from the CIS challenge page.", call. = FALSE)
  }

  list(
    action = action,
    fields = fields,
    seed = seed,
    prefix = cis_extract_pow_prefix(script)
  )
}

cis_solve_antibot_pow <- function(seed, prefix = "0000", max_attempts = cis_antibot_max_attempts()) {
  stopifnot(
    is.character(seed), length(seed) == 1, nzchar(seed),
    is.character(prefix), length(prefix) == 1, nzchar(prefix)
  )

  max_attempts <- suppressWarnings(as.numeric(max_attempts))
  if (length(max_attempts) != 1 || is.na(max_attempts) || max_attempts < 1) {
    stop("'max_attempts' must be a positive number.", call. = FALSE)
  }
  max_attempts <- floor(max_attempts)

  candidate <- 0
  while (candidate < max_attempts) {
    hash <- digest::digest(
      paste0(seed, format(candidate, scientific = FALSE, trim = TRUE)),
      algo = "sha256",
      serialize = FALSE
    )
    if (startsWith(hash, prefix)) {
      return(candidate)
    }
    candidate <- candidate + 1
  }

  stop(
    sprintf(
      "Could not solve the CIS proof-of-work challenge in %s attempts. Increase option 'opencis.antibot.max_attempts' if the site increased its difficulty.",
      format(max_attempts, scientific = FALSE, trim = TRUE)
    ),
    call. = FALSE
  )
}

cis_perform_get <- function(url, session, ...) {
  httr::GET(
    url,
    httr::timeout(cis_request_timeout()),
    httr::user_agent(session$user_agent),
    handle = session$handle,
    ...
  )
}

cis_complete_antibot <- function(resp, request_url, session) {
  challenge <- cis_parse_antibot_challenge(resp, request_url)
  solution <- cis_solve_antibot_pow(challenge$seed, challenge$prefix)
  challenge$fields[["challenge"]] <- format(solution, scientific = FALSE, trim = TRUE)

  verification <- httr::POST(
    challenge$action,
    httr::timeout(cis_request_timeout()),
    httr::user_agent(session$user_agent),
    httr::add_headers(
      Origin = cis_url_origin(request_url),
      Referer = request_url,
      Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    ),
    httr::config(followlocation = FALSE),
    handle = session$handle,
    body = challenge$fields,
    encode = "form"
  )

  status <- httr::status_code(verification)
  if (status >= 400) {
    stop(
      sprintf("The CIS server rejected the proof-of-work challenge (HTTP %s).", status),
      call. = FALSE
    )
  }

  invisible(verification)
}

cis_get <- function(url, ..., required = FALSE, context = "request") {
  request_args <- list(...)
  cached <- cis_cache_get_response(url, request_args)
  if (!is.null(cached)) {
    return(cached)
  }

  session <- cis_http_session(url)
  resp <- tryCatch(
    cis_get_with_retry(url, session, ...),
    error = function(e) {
      if (required) {
        stop(sprintf("Failed %s for '%s': %s", context, url, conditionMessage(e)), call. = FALSE)
      }
      warning(sprintf("Failed %s for '%s': %s", context, url, conditionMessage(e)), call. = FALSE)
      NULL
    }
  )

  if (is.null(resp)) {
    return(NULL)
  }

  if (cis_is_antibot_challenge(resp)) {
    if (!isTRUE(getOption("opencis.antibot", TRUE))) {
      msg <- sprintf("CIS anti-bot challenge encountered while %s for '%s'.", context, url)
      if (required) stop(msg, call. = FALSE) else warning(msg, call. = FALSE)
      return(NULL)
    }

    completed <- tryCatch(
      {
        cis_complete_antibot(resp, url, session)
        TRUE
      },
      error = function(e) {
        if (required) {
          stop(
            sprintf("Failed CIS anti-bot verification for '%s': %s", url, conditionMessage(e)),
            call. = FALSE
          )
        }
        warning(
          sprintf("Failed CIS anti-bot verification for '%s': %s", url, conditionMessage(e)),
          call. = FALSE
        )
        FALSE
      }
    )

    if (!completed) {
      return(NULL)
    }

    resp <- tryCatch(
      cis_get_with_retry(url, session, ...),
      error = function(e) {
        if (required) {
          stop(sprintf("Failed %s for '%s': %s", context, url, conditionMessage(e)), call. = FALSE)
        }
        warning(sprintf("Failed %s for '%s': %s", context, url, conditionMessage(e)), call. = FALSE)
        NULL
      }
    )

    if (is.null(resp)) {
      return(NULL)
    }
    if (cis_is_antibot_challenge(resp)) {
      msg <- paste0(
        "The CIS anti-bot challenge was still present after verification. ",
        "The server may now require browser signals not represented in the published challenge."
      )
      if (required) stop(msg, call. = FALSE) else warning(msg, call. = FALSE)
      return(NULL)
    }
  }

  status <- httr::status_code(resp)
  if (status >= 400) {
    msg <- sprintf("HTTP %s while %s for '%s'.", status, context, url)
    if (required) {
      stop(msg, call. = FALSE)
    }
    warning(msg, call. = FALSE)
    return(NULL)
  }

  cis_cache_set_response(url, resp)
  attr(resp, "opencis_cache") <- FALSE
  resp
}
