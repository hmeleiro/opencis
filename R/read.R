#' Import a CIS study
#'
#' Download and import the data of a CIS study.
#'
#' @param study_code A string with the study code.
#'
#' @importFrom haven read_sav
#' @importFrom utils download.file unzip
#'
#' @return A data.frame.
#'
#' @export
read_cis <- function(study_code) {
  BASEURL <- "https://www.cis.es/documents/d/cis/MD%s"
  url <- sprintf(BASEURL, study_code)

  tmpfile <- tempfile(fileext = ".zip")
  download.file(url, tmpfile, mode = "wb")

  files_in_zip <- unzip(tmpfile, list = TRUE)
  savfile <- files_in_zip[grepl("\\.sav$", files_in_zip$Name),]

  if(nrow(savfile) == 1) {
    savfile <- unz(tmpfile, filename = savfile$Name)
    data <- read_sav(savfile)
    return(data)
  } else {
    stop("No sav file found (or more than one exists in zip file)")
  }
}

#' Import a CIS timeseries
#'
#' Download and import the data of a CIS timeseries.
#'
#' @param series_code A string with the timeseries code.
#'
#' @importFrom httr GET
#' @importFrom haven read_sav
#'
#' @return A data.frame.
#'
#' @export
read_series <- function(series_code) {
  BASEURL <- "https://www.cis.es/o/cis/serie/%s"
  url <- sprintf(BASEURL, series_code)
  res <- GET(url)
  data <- parse_response_series(res)
  return(data)
}

