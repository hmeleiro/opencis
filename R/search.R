#' Search for CIS studies.
#'
#' Searches for CIS studies using the CIS search engine.
#'
#' @param search_terms A string with the search terms.
#' @param category_code A string (or a character vector if more than one) with the category code. The category code corresponds to the values of the `codigo` column in the data.frame output of the `get_study_categories()` function.
#' @param collection_code A string (or a character vector if more than one) with the collection code. The collection code corresponds to the values of the `codigo` column in the data.frame output of the `get_study_colections()` function.
#' @param since_date A string with the start date of the search in \%d-\%m-\%Y format.
#' @param until_date A string with the end date of the search in \%d-\%m-\%Y format.
#' @param study_code A string with the study code wanted.
#' @param since_study_code A string with the first study code wanted.
#' @param until_study_code A string with the last study code wanted.
#'
#' @importFrom httr POST
#' @importFrom httr add_headers
#' @importFrom dplyr mutate
#' @importFrom dplyr arrange
#' @importFrom dplyr desc
#' @importFrom rlang .data
#'
#'
#' @return A data.frame.
#'
#' @export
search_studies <- function(search_terms= NULL, category_code = NULL, collection_code = NULL,
                           since_date = NULL, until_date = NULL, study_code = NULL,
                           since_study_code = NULL, until_study_code = NULL) {

  if(!is.null(study_code)) {
    if(!is.null(since_study_code) | !is.null(until_study_code) ) {
      message("If study_code is specified, since_study_code and until_study_code are ignored")
    }
    cndNumeroEstudioDesde <- study_code
    cndNumeroEstudioHasta <- study_code
  } else {
    cndNumeroEstudioDesde <- since_study_code
    cndNumeroEstudioHasta <- until_study_code
  }

  BASEURL <- "https://www.cis.es/o/cis/estudios"
  body <- list(
    registrosPorPagina = -1,
    cndPalabras = search_terms,
    cndTematicoCod = category_code,
    cndFechaEstudioDesde = since_date,
    cndFechaEstudioHasta = until_date,
    cndNumeroEstudioDesde = cndNumeroEstudioDesde,
    cndNumeroEstudioHasta = cndNumeroEstudioHasta,
    cndColeccionCod = collection_code
  )

  res <- POST(BASEURL,
              add_headers("Origin" = "https://www.cis.es",
                          "Referer" = "https://www.cis.es/catalogo-estudios/resultados-definidos/buscador-estudios"),
              body=body,
              encode = "form")
  data <- parse_response(res)
  data <- data |>
    mutate(fecha = as.Date(.data$fecha, format = "%d-%m-%Y")) |>
    arrange(desc(.data$fecha))
  return(data)
}

#' Search for CIS questions.
#'
#' Searches for CIS questions using the CIS search engine.
#'
#' @param search_terms A string with the search terms.
#' @param descriptor_code A string (or a character vector if more than one) with the descriptor code. The descriptor code corresponds to the values of the `codigo` column in the data.frame output of the `get_question_categories()` function.
#' @param collection_code A string (or a character vector if more than one) with the collection code. The collection code corresponds to the values of the `codigo` column in the data.frame output of the `get_study_colections()` function.
#' @param since_date A string with the start date of the search in \%d-\%m-\%Y format.
#' @param until_date A string with the end date of the search in \%d-\%m-\%Y format.
#' @param study_code A string with the study code wanted.
#' @param since_study_code A string with the first study code wanted.
#' @param until_study_code A string with the last study code wanted.
#'
#' @importFrom httr POST
#' @importFrom httr add_headers
#' @importFrom dplyr mutate arrange desc
#'
#' @return A data.frame.
#'
#' @export
search_questions <- function(search_terms = NULL, descriptor_code = NULL, collection_code = NULL,
                             since_date = NULL, until_date = NULL, study_code = NULL,
                             since_study_code = NULL, until_study_code = NULL) {

  if(!is.null(study_code)) {
    if(!is.null(since_study_code) | !is.null(until_study_code) ) {
      message("If study_code is specified, since_study_code and until_study_code are ignored")
    }
    cndNumeroEstudioDesde <- study_code
    cndNumeroEstudioHasta <- study_code
  } else {
    cndNumeroEstudioDesde <- since_study_code
    cndNumeroEstudioHasta <- until_study_code
  }

  BASEURL <- "https://www.cis.es/o/cis/preguntas"
  body <- list(
    registrosPorPagina = 5000,
    cndPalabrasPre = search_terms,
    cndDescriptoresCod = paste0(descriptor_code, collapse =  ","),
    cndFechaEstudioDesde = since_date,
    cndFechaEstudioHasta = until_date,
    cndNumeroEstudioDesde = cndNumeroEstudioDesde,
    cndNumeroEstudioHasta = cndNumeroEstudioHasta,
    cndPalabras = "" # This is a hack to avoid an empty response
  )

  res <- POST(BASEURL,
              add_headers("Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"),
              body = body, encode = "form")
  data <- parse_response(res)


  data <- data |>
    mutate(fecha_estudio = as.Date(.data$fecha_estudio, format = "%d-%m-%Y")) |>
    arrange(desc(.data$fecha_estudio))
  return(data)
}

#' Search for CIS timeseries
#'
#' Searches for CIS timeseries using the CIS search engine.
#'
#' @param search_terms A string with the search terms.
#' @param subject_code A string (or a character vector if more than one) with the subject code. The subject code corresponds to the values of the `dmindex` column in the data.frame output of the `get_series_category()` function.
#' @param since_date A string with the start date of the search in \%d-\%m-\%Y format.
#' @param until_date A string with the end date of the search in \%d-\%m-\%Y format.
#' @param series_code A string with the series code wanted. The series code corresponds to the values of the `dmvariable` column in the data.frame output of the `get_series_category()` function.
#' @param since_series_code A string with the first series code wanted. The series code corresponds to the values of the `dmvariable` column in the data.frame output of the `get_series_category()` function.
#' @param until_series_code A string with the last series code wanted. The series code corresponds to the values of the `dmvariable` column in the data.frame output of the `get_series_category()` function.
#'
#' @importFrom httr POST
#' @importFrom httr add_headers
#' @importFrom dplyr mutate
#' @importFrom dplyr arrange
#' @importFrom dplyr desc
#'
#'
#' @return A data.frame.
#'
#' @export
search_series <- function(search_terms = NULL, subject_code = NULL,
                          since_date = NULL, until_date = NULL, series_code = NULL,
                          since_series_code = NULL, until_series_code = NULL) {

  if(!is.null(series_code)) {
    if(!is.null(since_series_code) | !is.null(until_series_code) ) {
      message("If series_code is specified, since_series_code and until_series_code are ignored")
    }
    cndCodigoSerieDesde <- series_code
    cndCodigoSerieHasta <- series_code
  } else {
    cndCodigoSerieDesde <- since_series_code
    cndCodigoSerieHasta <- until_series_code
  }

  BASEURL <- "https://www.cis.es/o/cis/series"
  body <- list(
    registrosPorPagina = -1,
    cndTituloSerie = search_terms,
    cndFechaEstudioDesde = since_date,
    cndFechaEstudioHasta = until_date,
    cndCodigoSerieDesde = cndCodigoSerieDesde,
    cndCodigoSerieHasta = cndCodigoSerieHasta,
    cndTemasCod = subject_code
  )
  res <- POST(BASEURL,
              add_headers("Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"),
              body = body, encode = "form")
  data <- parse_response(res)
  return(data)
}
