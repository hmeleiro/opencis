#' Retrieve the downloadable of a CIS study.
#'
#' Retrieves a list of files that can be downloaded asociated with a specific CIS study.
#' This includes pdf and html files (such as questionnaires, frecuency reports or methodogical notes)
#' and zip files with the individual level data (usually in SPSS sav format, but not always).
#'
#' @param study_code A string with the study code.
#'
#' @return A data.frame.
#'
#' @importFrom httr GET add_headers
#' @importFrom dplyr as_tibble mutate
#' @importFrom purrr map_df
#' @importFrom rlang .data
#'
#' @export
downloadable_files <- function(study_code) {
  BASEURL <- "https://www.cis.es/o/ficheros/estudio/20120/1503510/%s"
  url <- sprintf(BASEURL, study_code)
  res <- GET(url,
             add_headers("Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"))

  if(res$status_code == 200) {
    res_content <- content(res, "parsed")

    if(is.null(res_content$ficheros)) {
      message("No downloadable files found.")
      return(NULL)
    }

    data <- map_df(res_content$ficheros, as.data.frame)
    data <- as_tibble(data) |>
      mutate(url = sprintf("https://www.cis.es/documents/d/cis/%s", .data$title))
    return(data)
  } else {
    stop(sprintf("Error %s in request", res$status_code))
  }

}
#' Browse a CIS study questionnaire
#'
#' Opens a pdf url with the questionnaire of a specific CIS study.
#'
#' @param study_code A string with the study code.
#'
#' @return NULL
#'
#' @importFrom utils browseURL
#' @importFrom dplyr filter mutate
#' @importFrom rlang .data
#'
#' @export
browse_questionnaire <- function(study_code) {
  files <- downloadable_files(study_code)

  if(is.null(files)) {
    return(NULL)
  }
  questionnaire <- files |> filter(tolower(.data$tipo) == "cuestionario" | grepl("cues", .data$title))

  if(nrow(questionnaire) > 0) {
    extension <- questionnaire$extension
    if(extension == "zip") {
      message("The questionnaire is stored inside a zip file. Check the download folder.")
    }

    browseURL(questionnaire$url)
  } else {
    stop("No questionnaire found.")
  }
}
