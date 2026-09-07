#' Clear the opencis session cache
#'
#' Clears the in-memory cache used by \code{\link{search_cis}} and
#' \code{\link{read_cis}}, the persistent HTTP disk cache, and the HTTP sessions
#' and their cookies. Call this to force fresh data or a fresh CIS anti-bot
#' verification.
#'
#' @param disk Logical. If \code{TRUE} (the default), also remove all entries
#'   from the persistent HTTP cache. Set it to \code{FALSE} to retain downloaded
#'   responses between sessions.
#'
#' @return \code{NULL} invisibly.
#'
#' @export
clear_cache <- function(disk = TRUE) {
  memoise::forget(search_cis)
  memoise::forget(read_cis)
  if (isTRUE(disk)) {
    cis_clear_disk_cache()
  }
  cis_reset_http_sessions()
  invisible(NULL)
}
