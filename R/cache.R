.opencis_cache_state <- new.env(parent = emptyenv())
.opencis_cache_state$backend <- NULL
.opencis_cache_state$signature <- NULL
.opencis_cache_state$warned_signature <- NULL

cis_cache_enabled <- function() {
  isTRUE(getOption("opencis.cache", TRUE))
}

cis_cache_dir <- function() {
  configured <- getOption("opencis.cache_dir", NULL)
  if (is.character(configured) && length(configured) == 1 && nzchar(configured)) {
    return(normalizePath(path.expand(configured), mustWork = FALSE))
  }

  if (exists("R_user_dir", envir = asNamespace("tools"), inherits = FALSE)) {
    return(tools::R_user_dir("opencis", which = "cache"))
  }

  # R < 4.0 does not provide tools::R_user_dir(). Use a session cache there.
  file.path(tempdir(), "opencis-cache")
}

cis_cache_max_age <- function() {
  max_age <- suppressWarnings(as.numeric(getOption("opencis.cache_max_age", 86400)))
  if (length(max_age) != 1 || is.na(max_age) || max_age < 0) {
    return(86400)
  }
  max_age
}

cis_cache_max_size <- function() {
  max_size <- suppressWarnings(as.numeric(
    getOption("opencis.cache_max_size", 512 * 1024^2)
  ))
  if (length(max_size) != 1 || is.na(max_size) || max_size <= 0) {
    return(512 * 1024^2)
  }
  max_size
}

cis_cache_signature <- function() {
  list(
    directory = cis_cache_dir(),
    max_age = cis_cache_max_age(),
    max_size = cis_cache_max_size()
  )
}

cis_cache_backend <- function(force = FALSE) {
  if (!force && (!cis_cache_enabled() || cis_cache_max_age() == 0)) {
    return(NULL)
  }

  signature <- cis_cache_signature()
  if (
    !is.null(.opencis_cache_state$backend) &&
      identical(.opencis_cache_state$signature, signature) &&
      !.opencis_cache_state$backend$is_destroyed()
  ) {
    return(.opencis_cache_state$backend)
  }

  backend <- tryCatch(
    {
      candidate <- suppressWarnings(cachem::cache_disk(
        dir = signature$directory,
        max_size = signature$max_size,
        max_age = signature$max_age,
        evict = "lru",
        destroy_on_finalize = FALSE,
        warn_ref_objects = FALSE
      ))
      if (candidate$is_destroyed()) {
        stop("the cache directory is unavailable")
      }
      candidate
    },
    error = function(e) {
      warning_signature <- paste(
        signature$directory,
        signature$max_age,
        signature$max_size,
        sep = "|"
      )
      if (!identical(.opencis_cache_state$warned_signature, warning_signature)) {
        warning(
          sprintf(
            "Could not initialize the opencis disk cache at '%s': %s",
            signature$directory,
            conditionMessage(e)
          ),
          call. = FALSE
        )
        .opencis_cache_state$warned_signature <- warning_signature
      }
      NULL
    }
  )

  .opencis_cache_state$backend <- backend
  .opencis_cache_state$signature <- signature
  backend
}

cis_reset_cache_backend <- function() {
  .opencis_cache_state$backend <- NULL
  .opencis_cache_state$signature <- NULL
  .opencis_cache_state$warned_signature <- NULL
  invisible(NULL)
}

cis_cache_key <- function(url) {
  digest::digest(
    paste0("opencis-http-v1\n", enc2utf8(url)),
    algo = "sha256",
    serialize = FALSE
  )
}

cis_write_disk_path <- function(request_args) {
  for (argument in request_args) {
    if (!is.list(argument) || is.null(argument$output)) {
      next
    }
    if (inherits(argument$output, "write_disk")) {
      return(argument$output$path)
    }
  }
  NULL
}

cis_build_cached_response <- function(entry, request_args) {
  response_content <- entry$content
  disk_path <- cis_write_disk_path(request_args)

  if (!is.null(disk_path)) {
    connection <- file(disk_path, open = "wb")
    on.exit(close(connection), add = TRUE)
    writeBin(entry$content, connection)
    response_content <- disk_path
  }

  response <- structure(
    list(
      url = entry$response_url,
      status_code = entry$status_code,
      headers = entry$headers,
      all_headers = list(),
      cookies = data.frame(),
      content = response_content,
      date = entry$stored_at,
      times = c(total = 0),
      request = list(method = "GET", url = entry$request_url),
      handle = NULL
    ),
    class = "response"
  )
  attr(response, "opencis_cache") <- TRUE
  response
}

cis_cache_get_response <- function(url, request_args = list()) {
  backend <- cis_cache_backend()
  if (is.null(backend)) {
    return(NULL)
  }

  key <- cis_cache_key(url)
  entry <- tryCatch(backend$get(key), error = function(e) cachem::key_missing())
  if (cachem::is.key_missing(entry)) {
    return(NULL)
  }

  valid <- is.list(entry) &&
    identical(entry$schema, 1L) &&
    is.raw(entry$content) &&
    is.numeric(entry$status_code) &&
    length(entry$status_code) == 1
  if (!valid) {
    try(backend$remove(key), silent = TRUE)
    return(NULL)
  }

  tryCatch(
    cis_build_cached_response(entry, request_args),
    error = function(e) {
      warning(
        sprintf("Could not restore cached response for '%s': %s", url, conditionMessage(e)),
        call. = FALSE
      )
      NULL
    }
  )
}

cis_cache_set_response <- function(url, resp) {
  backend <- cis_cache_backend()
  if (is.null(backend)) {
    return(invisible(FALSE))
  }

  status <- httr::status_code(resp)
  if (status < 200 || status >= 300 || cis_is_antibot_challenge(resp)) {
    return(invisible(FALSE))
  }

  response_content <- tryCatch(
    httr::content(resp, as = "raw"),
    error = function(e) NULL
  )
  if (is.null(response_content) || length(response_content) > cis_cache_max_size()) {
    return(invisible(FALSE))
  }

  response_headers <- httr::headers(resp)
  if (length(response_headers) > 0 && !is.null(names(response_headers))) {
    response_headers <- response_headers[
      tolower(names(response_headers)) != "set-cookie"
    ]
  }
  names(response_headers) <- tolower(names(response_headers))
  class(response_headers) <- unique(c("insensitive", class(response_headers)))

  entry <- list(
    schema = 1L,
    request_url = url,
    response_url = resp$url,
    status_code = status,
    headers = response_headers,
    content = response_content,
    stored_at = Sys.time()
  )

  stored <- tryCatch(
    {
      backend$set(cis_cache_key(url), entry)
      TRUE
    },
    error = function(e) {
      warning(
        sprintf("Could not cache response for '%s': %s", url, conditionMessage(e)),
        call. = FALSE
      )
      FALSE
    }
  )
  invisible(stored)
}

cis_clear_disk_cache <- function() {
  backend <- cis_cache_backend(force = TRUE)
  if (!is.null(backend)) {
    tryCatch(
      backend$reset(),
      error = function(e) {
        warning(
          sprintf("Could not clear the opencis disk cache: %s", conditionMessage(e)),
          call. = FALSE
        )
      }
    )
  }
  cis_reset_cache_backend()
  invisible(NULL)
}

#' Inspect the opencis HTTP cache
#'
#' Reports the active disk-cache configuration and current usage. The cache is
#' enabled by default and stores successful CIS responses for 24 hours.
#'
#' Configure it with the options \code{opencis.cache},
#' \code{opencis.cache_dir}, \code{opencis.cache_max_age} (seconds), and
#' \code{opencis.cache_max_size}
#' (bytes).
#'
#' @return A named list containing the cache state, directory, limits, number
#'   of entries, and current size in bytes.
#'
#' @export
cache_info <- function() {
  enabled <- cis_cache_enabled() && cis_cache_max_age() > 0
  backend <- if (enabled) cis_cache_backend() else NULL

  list(
    enabled = enabled && !is.null(backend),
    directory = cis_cache_dir(),
    max_age = cis_cache_max_age(),
    max_size = cis_cache_max_size(),
    entries = if (is.null(backend)) 0L else length(backend$keys()),
    size = if (is.null(backend)) 0 else backend$size()
  )
}
