#' Package imports
#'
#' These declarations ensure NAMESPACE keeps required imports.
#' @title Imports
#' @description Package import declarations
#' @name opencis-imports
#' @keywords internal
#' @importFrom httr GET status_code content write_disk stop_for_status modify_url
#' @importFrom haven read_sav
#' @importFrom utils unzip browseURL
#' @importFrom rvest html_elements html_element html_attr html_text
#' @importFrom magrittr %>%
#' @importFrom purrr map list_rbind
#' @importFrom tibble tibble as_tibble
#' @importFrom stringr str_extract_all
#' @importFrom memoise memoise forget
NULL
