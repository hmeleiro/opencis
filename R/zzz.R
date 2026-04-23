.onLoad <- function(libname, pkgname) {
  # Wrap the two main HTTP-heavy functions with session-level caching.
  # Repeated calls with identical arguments return the cached result
  # without hitting the network again.
  search_cis <<- memoise::memoise(search_cis)
  read_cis   <<- memoise::memoise(read_cis)
}


#' Clear the opencis session cache
#'
#' Clears the in-memory cache used by \code{\link{search_cis}} and
#' \code{\link{read_cis}}. Call this when you want to force fresh data
#' to be retrieved from the CIS server within the same R session.
#'
#' @return \code{NULL} invisibly.
#'
#' @export
clear_cache <- function() {
  memoise::forget(search_cis)
  memoise::forget(read_cis)
  invisible(NULL)
}
