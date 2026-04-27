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
#' @example R/examples/search_cis.R
search_cis <- function(
  start = 1,
  q = "",
  from = NULL, # Date o NULL
  to = NULL, # Date o NULL
  sort = "relevance",
  catalogo = "estudio",
  ...
) {
  args <- as.list(environment(), all = TRUE)
  url <- do.call(cis_catalog_url_date, args)

  resp <- cis_get(url, required = FALSE, context = "searching CIS catalog")

  if (is.null(resp)) {
    return(NULL)
  }

  if (status_code(resp) == 200) {
    if (catalogo == "estudio") {
      out <- parse_study(resp)
    } else if (catalogo == "pregunta") {
      out <- parse_question(resp)
    } else if (catalogo == "serie") {
      out <- parse_serie(resp)
    } else {
      stop("Invalid catalogo value. Must be 'estudio', 'pregunta' or 'serie'.")
    }
  } else {
    return(NULL)
  }

  return(out)
}

#' Parse CIS study search results
#'
#' @param resp The HTTP response object from the CIS search.
#'
#' @return A tibble with the parsed studies information.
#'
#' @keywords internal
parse_study <- function(resp) {
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
      date <- html_elements(x, "li")[1]
      study <- html_elements(x, "li")[2]
      date <- html_text(date)
      date <- as.Date(date, "%d/%m/%Y")
      study <- html_text(study)
      study <- gsub("^Estudio\\s+", "", study)
      tibble(study, date)
    }) %>%
    list_rbind()


  out <- tibble(
    title = titles,
    url = urls
  )
  out <- cbind(card_info, out)
  out <- as_tibble(out)
}

#' Parse CIS data series search results
#'
#' @param resp The HTTP response object from the CIS search.
#'
#' @return A tibble with the parsed data series information.
#'
#' @keywords internal
parse_serie <- function(resp) {
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
      from <- html_elements(x, "li")[1]
      to <- html_elements(x, "li")[2]
      serie <- html_elements(x, "li")[3]

      from <- html_text(from)
      from <- as.Date(from, "%d/%m/%Y")
      to <- html_text(to)
      to <- as.Date(to, "%d/%m/%Y")
      serie <- html_text(serie)
      serie <- gsub("^Serie\\s+", "", serie)
      tibble(serie, from, to)
    }) %>%
    list_rbind()


  out <- tibble(
    title = titles,
    url = urls
  )
  out <- cbind(card_info, out)
  out <- as_tibble(out)
}


#' Parse CIS question search results
#'
#' @param resp The HTTP response object from the CIS search.
#'
#' @return A tibble with the parsed data series information.
#'
#' @keywords internal
parse_question <- function(resp) {
  html <- content(resp, "parsed")

  card_content <-
    html %>%
    html_elements(".card-content")

  a <- card_content %>%
    html_element("a")

  titles <- html_attr(a, name = "title")
  urls <- html_attr(a, "href")

  card_info <- html %>%
    html_elements(".card-content") %>%
    html_element(".card-info")

  card_info <-
    map(card_info, function(x) {
      date <- html_elements(x, "li")[1]
      question <- html_elements(x, "li")[2]
      date <- html_text(date)
      date <- as.Date(date, "%d/%m/%Y")
      question <- html_text(question)
      question <- gsub("^Pregunta\\s+", "", question)
      tibble(question, date)
    }) %>%
    list_rbind()

  out <- tibble(
    title = titles,
    url = urls
  )
  out <- cbind(card_info, out)
  out <- as_tibble(out)
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
  studies <- search_cis(q = study_code)

  if (is.null(studies)) {
    message("Could not retrieve study index.")
    return(NULL)
  }

  if (nrow(studies) == 0) {
    message("No study found.")
    return(NULL)
  }


  match_study <- studies[studies$study == study_code, ]

  if (nrow(match_study) > 1) {
    message("More than one study found. Returning the first one.")
    return(match_study$url[1])
  }

  if (nrow(match_study) == 0) {
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
  start = 1,
  q = "",
  from = NULL, # Date o NULL
  to = NULL, # Date o NULL
  sort = "relevance",
  catalogo = "estudio",
  ...
) {
  if (sort == "relevance") {
    sort <- ""
  }

  base <- "https://www.cis.es/es/estudios/catalogo"

  # Construir from / fromDate
  if (!is.null(from)) {
    from <- as.Date(from)
    stopifnot(inherits(from, "Date"))
    from_str <- format(from, "%Y-%m-%d")
    from_range <- sprintf("[%s000000 now]", format(from, "%Y%m%d"))
    fromDate_val <- from_str
  } else {
    from_range <- ""
    fromDate_val <- ""
  }

  # Construir to / toDate
  if (!is.null(to)) {
    to <- as.Date(to)
    stopifnot(inherits(to, "Date"))
    to_str <- format(to, "%Y-%m-%d")
    # Aquí puedes ajustar la lógica según cómo quieras el rango.
    # Ejemplo: desde hace 100 años hasta 'to' a las 23:59:59
    to_range <- sprintf("[now-100y %s235959]", format(to, "%Y%m%d"))
    toDate_val <- to_str
  } else {
    # Sin límite explícito: mismo comportamiento raro/flexible que usan ellos
    to_range <- "[now-100y ]"
    toDate_val <- ""
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


#' Search all CIS results with automatic pagination
#'
#' Calls \code{\link{search_cis}} repeatedly, incrementing the page index until
#' no more results are returned, and returns all results in a single tibble.
#'
#' @param q String. The search query. Default is an empty string.
#' @param from Date or NULL. The start date for filtering results. Default is NULL.
#'   The date format must be "YYYY-MM-DD".
#' @param to Date or NULL. The end date for filtering results. Default is NULL.
#'   The date format must be "YYYY-MM-DD".
#' @param sort String. The sorting order for the results
#'   (\code{"publishDate-"}, \code{"publishDate+"}, \code{"relevance"}).
#'   Default is \code{"relevance"}.
#' @param catalogo String. The catalog type (\code{"estudio"}, \code{"pregunta"},
#'   \code{"serie"}). Default is \code{"estudio"}.
#' @param ... Additional parameters passed to \code{\link{search_cis}}.
#'
#' @return A tibble with all search results across all pages.
#'
#' @export
#'
#' @example R/examples/search_all_cis.R
search_all_cis <- function(
  q = "",
  from = NULL,
  to = NULL,
  sort = "relevance",
  catalogo = "estudio",
  ...
) {
  all_results <- list()
  page <- 1

  repeat {
    results <- search_cis(
      start    = page,
      q        = q,
      from     = from,
      to       = to,
      sort     = sort,
      catalogo = catalogo,
      ...
    )

    if (is.null(results) || nrow(results) == 0) break

    all_results[[page]] <- results
    page <- page + 1
  }

  if (length(all_results) == 0) {
    return(tibble())
  }

  list_rbind(all_results)
}


#' Get metadata of a CIS study
#'
#' Retrieves the technical metadata of a CIS study from its detail page,
#' including study dates, type, country, author, and thematic indices.
#'
#' @param study_code A string with the study code.
#'
#' @return A tibble with two columns: \code{field} and \code{value}.
#'
#' @export
#'
#' @example R/examples/get_metadata.R
get_metadata <- function(study_code) {
  url <- get_study_url(study_code)
  if (is.null(url)) {
    stop("Study '", study_code, "' not found.")
  }

  resp <- cis_get(url, required = TRUE, context = "retrieving study metadata")
  html <- content(resp, "parsed")

  # --- Date fields (.jdt-study-dates__item) ---
  date_labels <- trimws(html_text(html_elements(html, ".jdt-study-dates__label")))
  date_values <- trimws(html_text(html_elements(html, ".jdt-study-dates__date")))

  # --- Info items: each .last-container has a bold label + plain value ---
  info_items <- html_elements(html, ".jdt-detalle .last-container")
  info_labels <- character(0)
  info_values <- character(0)

  for (item in info_items) {
    ps <- html_elements(item, "p")
    if (length(ps) < 2) next
    label <- trimws(html_text(ps[[1]]))
    # For items with a list (e.g. "Indices tematicos"), prefer the list text
    lis <- html_elements(item, "li")
    if (length(lis) > 0) {
      value <- paste(trimws(html_text(lis)), collapse = "; ")
    } else {
      value <- trimws(html_text(ps[[2]]))
    }
    info_labels <- c(info_labels, label)
    info_values <- c(info_values, value)
  }

  tibble(
    field = c(date_labels, info_labels),
    value = c(date_values, info_values)
  )
}
