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
#' @return A data.frame with the study data.
#'
#' @export
#'
#' @example R/examples/read_cis.R
read_cis <- function(study_code, verbose = FALSE) {
  url <- get_study_url(study_code)
  data <- download_study(url)
  return(data)
}

#' Download and read a CIS study from a given URL
#'
#' @param url A string with the URL of the CIS study page.
#'
#' @keywords internal
download_study <- function(url) {

  html <- content(
    GET(url),
    as = "text", encoding = "UTF-8"
  )
  zip_url <- find_url(html)

  tmpfile <- tempfile(fileext = ".zip")
  resp_zip <- GET(
    zip_url,
    write_disk(tmpfile, overwrite = TRUE)
  )

  stop_for_status(resp_zip)

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

#' Find CIS study data URL in HTML content
#'
#' Searches for the URL of the CIS study data ZIP file within the provided HTML content.
#'
#' @param html A character string containing the HTML content to search.
#' @param ids An optional vector of two strings representing the numeric subroutes of the URL
#'           (e.g., c("3411", "3411") for "https://www.cis.es/documents/3411/3411/MD3411.zip").
#'           If NULL, the function searches for any valid CIS study data URL.
#' @param allow_uuid A boolean indicating whether to allow UUIDs in the URL.
#'                  Defaults to FALSE.
#'
#' @return A character vector of unique URLs found in the HTML content.
#'
#' @keywords internal
find_url <- function(html,
                     ids = NULL, # subrutas numéricas
                     allow_uuid = FALSE) {
  stopifnot(is.character(html), length(html) == 1)

  base_pat <- if (is.null(ids)) {
    "https://www\\.cis\\.es/documents/\\d+/\\d+/"
  } else {
    sprintf("https://www\\.cis\\.es/documents/%s/%s/", ids[1], ids[2])
  }

  md_part   <- "MD\\d+\\.zip"
  uuid_part <- if (allow_uuid) "(?:/[A-Za-z0-9-]+)?" else ""

  pat <- paste0(base_pat, md_part, uuid_part)

  out <- unlist(str_extract_all(html, pat))
  unique(out[!is.na(out) & nzchar(out)])
}
