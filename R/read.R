#' Import a CIS study
#'
#' Download and import the data of a CIS study.
#'
#' @param study_code A string with the study code.
#'
#' @importFrom haven read_sav
#' @importFrom utils unzip
#'
#' @return A data.frame with the study data.
#'
#' @export
#'
#' @example R/examples/read_cis.R
read_cis <- function(study_code) {
  url <- get_study_url(study_code)
  zip_path <- download_file(url)
  data <- read_sav_from_zip(zip_path)

  return(data)
}


#' Download and read a CIS study from a given URL
#'
#' @param url A string with the URL of the CIS study page.
#' @param destfile A string with the path where the ZIP file will be saved.
#'   Defaults to a temporary file.
#'
#' @keywords internal
download_file <- function(url, destfile = tempfile(fileext = ".zip")) {

  resp_html <- GET(url)
  stop_for_status(resp_html)
  html <- content(resp_html, as = "text", encoding = "UTF-8")

  zip_url <- find_url(html)
  if (length(zip_url) == 0) {
    stop("No ZIP URL found on the study page. The page structure may have changed.")
  }

  resp_zip <- GET(zip_url, write_disk(destfile, overwrite = TRUE))
  stop_for_status(resp_zip)

  return(destfile)

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


#' Read a SAV file from a ZIP archive
#'
#' Extracts and reads the SPSS (.sav) data file contained in a ZIP archive.
#'
#' @param zip_path A string with the path to the ZIP file.
#'
#' @return A data.frame with the data read from the .sav file.
#'
#' @keywords internal
read_sav_from_zip <- function(zip_path) {
  sav_file <- list_file_paths(zip_path, type = "sav")

  if(nrow(sav_file) == 1) {
    out_dir <- tempdir()
    sav_path <- unzip(zip_path, files = sav_file$Name, exdir = out_dir)

    data <- read_sav(sav_path, user_na = TRUE)
    return(data)
  } else if(nrow(sav_file) > 1) {
    stop("Found more than one sav file in zip file.")
  } else {
    stop("No sav file found.")
  }
}


#' List file paths inside a ZIP archive
#'
#' Returns a data.frame with the files contained in a ZIP archive,
#' optionally filtered by file extension.
#'
#' @param zip_file A string with the path to the ZIP file.
#' @param type A string with the file extension to filter by (e.g. \code{"sav"}, \code{"pdf"}).
#'   If \code{NULL} (default), all files are returned.
#'
#' @return A data.frame with the files in the ZIP archive.
#'
#' @keywords internal
list_file_paths <- function(zip_file, type = NULL) {
  files_in_zip <- unzip(zip_file, list = TRUE)

  if(is.null(type)) {
    return(files_in_zip)
  }

  files_type <- files_in_zip[grepl(sprintf("\\.%s$", type), files_in_zip$Name),]
  return(files_type)
}


#' Open the questionnaire PDF of a CIS study
#'
#' Opens a PDF document from a CIS study in the default browser.
#'
#' CIS study ZIP files typically contain two PDF documents:
#' \itemize{
#'   \item The \strong{questionnaire} (cuestionario): use \code{wanted_file = "cues"}.
#'   \item The \strong{technical sheet} (ficha técnica): use \code{wanted_file = "ft"}.
#' }
#'
#' @param study_code A string with the study code.
#' @param wanted_file A keyword used to match the PDF filename inside the ZIP.
#'   Use \code{"cues"} (default) for the questionnaire or \code{"ft"} for the
#'   technical sheet.
#'
#' @return Called for its side effect of opening the PDF in the browser.
#'   Returns \code{NULL} invisibly.
#'
#' @export
#'
#' @example R/examples/browse_pdf.R
browse_pdf <- function(study_code, wanted_file = "cues") {
  url <- get_study_url(study_code)
  zip_path <- download_file(url)

  pdf_files <- list_file_paths(zip_path, "pdf")

  pdf_file <- pdf_files[grepl(wanted_file, pdf_files$Name, ignore.case = TRUE),]

  if(nrow(pdf_file) == 1) {
    out_dir <- tempdir()
    pdf_path <- unzip(zip_path, files = pdf_file$Name, exdir = out_dir)
    browseURL(pdf_path)
  } else if(nrow(pdf_file) > 1) {
    stop(sprintf("Found more than one pdf file in zip file with keyword '%s'.", wanted_file))
  } else {
    stop(sprintf("No pdf file found in zip file with keyword '%s'.", wanted_file))
  }

  invisible(NULL)
}


#' Download a CIS study ZIP file to disk
#'
#' Downloads the data ZIP file for a CIS study to a specified directory,
#' instead of a temporary folder. Useful for projects that need to keep
#' the raw data files.
#'
#' @param study_code A string with the study code.
#' @param destdir A string with the directory where the ZIP file will be saved.
#'   Defaults to the current working directory.
#'
#' @return The path to the saved ZIP file, invisibly.
#'
#' @export
#'
#' @example R/examples/download_study.R
download_study <- function(study_code, destdir = ".") {
  url <- get_study_url(study_code)
  if (is.null(url)) {
    stop("Study '", study_code, "' not found.")
  }

  if (!dir.exists(destdir)) {
    stop("Directory does not exist: ", destdir)
  }

  destfile <- file.path(destdir, paste0("MD", study_code, ".zip"))
  path <- download_file(url, destfile = destfile)

  invisible(normalizePath(path))
}


#' Extract a data dictionary from a CIS study data frame
#'
#' Returns a tibble listing each variable in the data along with its
#' variable label and value labels, as loaded by \code{haven}.
#'
#' @param data A data.frame loaded from a CIS \code{.sav} file,
#'   typically the output of \code{\link{read_cis}}.
#'
#' @return A tibble with columns:
#'   \describe{
#'     \item{variable}{Variable name.}
#'     \item{label}{Variable label, or \code{NA} if none.}
#'     \item{value_labels}{A named numeric vector of value labels,
#'       or \code{NULL} for unlabelled variables (list-column).}
#'   }
#'
#' @export
#'
#' @example R/examples/get_data_dictionary.R
get_data_dictionary <- function(data) {
  if (!is.data.frame(data)) stop("'data' must be a data.frame.")

  vl <- lapply(data, function(x) attr(x, "label"))
  vv <- lapply(data, function(x) attr(x, "labels"))

  tibble(
    variable     = names(data),
    label        = vapply(vl, function(x) if (is.null(x)) NA_character_ else x, character(1)),
    value_labels = vv
  )
}
