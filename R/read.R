#' Import a CIS study
#'
#' Download and import the data of a CIS study.
#'
#' @param study_code A string with the study code.
#' @param verbose boolean. Controls the messages printed on the console.
#'
#' @importFrom haven read_sav
#' @importFrom utils download.file unzip
#'
#' @return A list of length 2 with the following values: 1) data: a data.frame with the individual-level data points for the timeseries. 2) metadata: a data.frame with the series code and their corresponding name
#'
#' @export
#'
#' @example R/examples/read_cis.R
read_cis <- function(study_code, verbose = FALSE) {
  BASEURL <- "https://www.cis.es/documents/d/cis/MD%s"
  url <- sprintf(BASEURL, study_code)

  tmpfile <- tempfile(fileext = ".zip")
  download.file(url, tmpfile, mode = "wb", quiet = ifelse(verbose, FALSE, TRUE))

  files_in_zip <- unzip(tmpfile, list = TRUE)
  savfile <- files_in_zip[grepl("\\.sav$", files_in_zip$Name),]

  if(nrow(savfile) == 1) {
    savfile <- unz(tmpfile, filename = savfile$Name)
    data <- read_sav(savfile, user_na = TRUE)
    return(data)
  } else if(nrow(savfile) > 1) {
    stop("Founded more than one sav file in zip file.")
  } else {
    stop("No sav file found.")
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
#'
#' @example R/examples/read_series.R
read_series <- function(series_code) {
  BASEURL <- "https://www.cis.es/o/cis/serie/%s"
  url <- sprintf(BASEURL, series_code)
  res <- GET(url)
  data <- parse_response_series(res)
  return(data)
}

#' Import the individual-level data for CIS timeseries
#'
#' `r lifecycle::badge("experimental")` Download and import the individual-level data for a CIS timeseries.
#'
#' @param series_code A string (or a character vector) with the timeseries codes.
#' @param since_date A string with the start date of the search in '%d-%m-%Y' format.
#' @param until_date A string with the end date of the search in '%d-%m-%Y' format.
#'
#' @importFrom purrr map_df
#' @importFrom haven read_sav
#'
#' @return A data.frame.
#'
#' @export
#'
read_series_microdata <- function(series_code, since_date = NULL, until_date = NULL) {
  studies <- series_study_codes(series_code, since_date, until_date)
  metadata <- studies$metadata
  studies <- studies$data
  study_ids <- unique(studies$study_code)

  if(length(study_ids) >  70) {
    cat("Downloading", length(study_ids), "studies from CIS. Make some coffee, this may take a while.")
  } else {
    cat("Downloading", length(study_ids), "studies from CIS.")
  }
  data <- map_df(study_ids, series_microdata, studies = studies)
  return(list(data = data, metadata = metadata))
}

