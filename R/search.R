#' Search for CIS studies.
#'
#' Searches for CIS studies using the CIS search engine.
#'
#' @param start Integer. The starting page for the search results. Default is 1, iterate to get more results.
#' @param q String. The search query. Default is an empty string.
#' @param from Date or NULL. The start date for filtering results. Default is NULL. The date format must be "YYYY-MM-DD".
#' @param to Date or NULL. The end date for filtering results. Default is NULL. The date format must be "YYYY-MM-DD".
#' @param sort String. The sorting order for the results ("publishDate-", "publishDate+", "relevance").
#' Default is "relevance".
#' @param catalogo String. The catalog type ("estudio", "pregunta", "serie"). Default is "estudio".
#' @param ... Additional parameters (not used).
#'
#' @return A data.frame with the search results.
#'
#' @export
#'
#' @example R/examples/search_studies.R
search_studies <- function(
    start    = 1,
    q        = "",
    from     = NULL,   # Date o NULL
    to       = NULL,   # Date o NULL
    sort     = "relevance",
    catalogo = "estudio",
    ...
) {

  args <- as.list(environment(), all=TRUE)
  url <- do.call(cis_catalog_url_date, args)

  resp <- GET(url)

  if(status_code(resp) == 200) {

    html <- content(resp, "parsed")
    a <-
      html %>%
      html_elements(".card-content") %>%
      html_element("a")


    titles <- html_attr(a, name = "title")
    urls <- html_attr(a, "href")


    card_info <- html %>%
      html_elements(".card-content") %>%
      html_element(".card-info")

    card_info <-
      map(card_info, function(x) {
        fecha <- html_elements(x, "li")[1]
        estudio <- html_elements(x, "li")[2]
        fecha <- html_text(fecha)
        fecha <- as.Date(fecha, "%d/%m/%Y")
        estudio <- html_text(estudio)
        estudio <- gsub("Estudio ", "", estudio)
        tibble(estudio, fecha)
      }) %>%
      list_rbind()


    out <- tibble(
      title = titles,
      url = urls
    )
    out <- cbind(card_info, out)
    out <- as_tibble(out)
  } else {
    NULL
  }

  return(out)
}

#' Get the URL of a CIS study
#'
#' Retrieves the URL of a specific CIS study using its study ID.
#'
#' @param study_code A string with the study ID.
#'
#' @return A string with the URL of the study, or NULL if not found.
#'
#' @keywords internal
get_study_url <- function(study_code) {
  URL_BASE <- "https://www.cis.es/es/estudios/catalogo?catalogo=estudio&sort=publishDate-&t=0&q=%s"
  url <- sprintf(URL_BASE, study_code)
  resp <- GET(url)

  studies <- search_studies(q = study_code)

  if(nrow(studies) == 0 ){
    message("No study found.")
    return(NULL)
  }


  match_study <- studies[studies$estudio == study_code, ]

  if(nrow(match_study) > 1) {
    message("More than one study found. Returning the first one.")
    return(match_study$url[1])
  }

  if(nrow(match_study) == 0 ){
    message("No study found.")
    return(NULL)
  }

  return(match_study$url)

}


#' Build CIS catalog URL with date range
#'
#' Constructs a URL for querying the CIS catalog with optional date range filters.
#'
#' @param start Integer. The starting page for the search results. Default is 1, iterate to get more results.
#' @param q String. The search query. Default is an empty string.
#' @param from Date or NULL. The start date for filtering results. Default is NULL
#' @param to Date or NULL. The end date for filtering results. Default is NULL.
#' @param sort String. The sorting order for the results ("publishDate-", "publishDate+", "relevance").
#' Default is "relevance".
#' @param catalogo String. The catalog type ("estudio", "pregunta", "serie"). Default is "estudio".
#' @param ... Additional parameters (not used).
#'
#' @return A string representing the constructed URL.
#'
#' @keywords internal
cis_catalog_url_date <- function(
    start    = 1,
    q        = "",
    from     = NULL,   # Date o NULL
    to       = NULL,   # Date o NULL
    sort     = "relevance",
    catalogo = "estudio",
    ...
) {

  if(sort == "relevance") {
    sort <- ""
  }

  base <- "https://www.cis.es/es/estudios/catalogo"

  # Construir from / fromDate
  if (!is.null(from)) {
    from <- as.Date(from)
    stopifnot(inherits(from, "Date"))
    from_str      <- format(from, "%Y-%m-%d")
    from_range    <- sprintf("[%s000000 now]", format(from, "%Y%m%d"))
    fromDate_val  <- from_str
  } else {
    from_range    <- ""
    fromDate_val  <- ""
  }

  # Construir to / toDate
  if (!is.null(to)) {
    to <- as.Date(to)
    stopifnot(inherits(to, "Date"))
    to_str        <- format(to, "%Y-%m-%d")
    # Aquí puedes ajustar la lógica según cómo quieras el rango.
    # Ejemplo: desde hace 100 años hasta 'to' a las 23:59:59
    to_range      <- sprintf("[now-100y %s235959]", format(to, "%Y%m%d"))
    toDate_val    <- to_str
  } else {
    # Sin límite explícito: mismo comportamiento raro/flexible que usan ellos
    to_range      <- "[now-100y ]"
    toDate_val    <- ""
  }

  params <- list(
    start     = start,
    q         = q,
    fromDate  = fromDate_val,
    from      = from_range,
    toDate    = toDate_val,
    to        = to_range,
    sort      = sort,
    catalogo  = catalogo
  )

  modify_url(base, query = params)
}
