#' Retrieve the categories of CIS studies.
#'
#' Retrieves the valid categories of CIS studies.
#' The values of the `codigo` column can be used in the `category_code`
#' parameter of the `search_studies()` function.
#'
#' @return A data.frame.
#'
#' @importFrom httr GET
#' @importFrom dplyr select rename
#'
#' @export
get_study_categories <- function() {
  BASEURL <- "https://www.cis.es/o/cis/tematicoarbol"
  res <- GET(BASEURL)
  data <- parse_response(res)
  return(data)
}

#' Retrieve the collection categories of CIS studies.
#'
#' Retrieves the valid collection categories of CIS studies.
#' The values of the `codigo` column can be used in the `collection_code`
#' parameter of the `search_studies()` of `search_questions()` functions.
#'
#'
#' @return A data.frame.
#'
#' @importFrom httr GET
#' @importFrom dplyr select rename
#' @importFrom rlang .data
#'
#' @export
get_study_colections <- function() {
  BASEURL <- "https://www.cis.es/o/cis/colecciones"
  res <- GET(BASEURL)
  data <- parse_response(res) |>
    select(-c(.data$codigo, .data$conteo)) |>
    rename(codigo = .data$id)
  return(data)
}

#' Retrieve the categories of CIS questions.
#'
#' Retrieves the valid categories of CIS questions.
#' The values of the `codigo` column can be used in the `descriptor_code`
#' parameter of the `search_questions()` function.
#'
#' @return A data.frame.
#'
#' @importFrom httr GET
#'
#' @export
get_question_categories <- function() {
  BASEURL <- "https://www.cis.es/o/cis/descriptoresarbol"
  res <- GET(BASEURL)
  data <- parse_response(res)
  return(data)
}

#' Retrieve the categories of CIS timeseries.
#'
#' Retrieves the valid categories of CIS timeseries.
#' The values of the `dmindex` column can be used in the `subject_code`
#' parameter of the `search_series()` function. The values of the `dmvariable`
#' columns can be used in the `series_code`, `since_series_code`, and `until_series_code`
#' parameters of the `search_series()`.
#'
#' @return A data.frame.
#'
#' @importFrom httr GET
#' @importFrom dplyr select any_of
#'
#' @export
get_series_category <- function() {
  BASEURL <- "https://www.cis.es/o/cis/seriesarbol"
  res <- GET(BASEURL)
  rm_cols <- c("dmnotas", "dmnotasext", "dmiddi", "dmestado", "dmformato", "dmlongitud", "dmdecimales")
  data <- parse_response(res) |>
    select(!any_of(rm_cols))
  return(data)
}
