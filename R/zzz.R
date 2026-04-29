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
