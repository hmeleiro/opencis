#' General parser for responses from the CIS API.
#'
#' @param res A response object from a httr request.
#' @return A data.frame with the parsed response.
#'
#' @importFrom httr content
#' @importFrom tibble as_tibble
#' @importFrom dplyr rename
#'
#' @keywords Internal
#' @noRd
parse_response <- function(res) {
  if(res$status_code == 200) {
    res_content <- content(res, "parsed")
    if("registros" %in% names(res_content)) {
      if(res_content$registros == 0) {
        message("No results found")
        return(NULL)
      } else if(res_content$registros > length(res_content$lista)) {
        message(sprintf("The search yielded too many results.\nReturning only %s of %s results.\nNarrow and divide your search into multiple petitions to retrieve all the results.", length(res_content$lista), res_content$registros))
      }
    }
    data <- flatten_series(res_content)
    data <- as_tibble(data)
    return(data)
  } else {
    stop(sprintf("Error %s in request", res$status_code))
  }
}

#' Specific parser of response from the /cis/serie/ endpoint of the CIS API.
#'
#' @param res A response object from a httr request.
#' @return A data.frame with the parsed response.
#'
#' @importFrom httr content
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr rename
#'
#' @keywords Internal
#' @noRd
parse_response_series <- function(res) {
  if(res$status_code == 200) {
    res_content <- content(res, "parsed")

    if(!res_content$success) {
      stop(res_content$respuesta)
    }
    response_categories <- unlist(res_content$ficha$filas)

    i <- grep("Media|Desv.Tip.|Desv.T\\u00edp.|\\(N\\)|^N$", response_categories)
    response_metadata_categories <- response_categories[i]
    response_categories <- gsub(" $|^ ", "", response_categories[-i])

    question_data <- map_df(res_content$ficha$serie_temporal, function(x) {
      response_values <- unlist(x$datos)
      response_values <- as.numeric(gsub("[()]", "", response_values))
      response_metadata_values <- response_values[i]
      response_values <- response_values[-i]


      names(response_metadata_values) <- response_metadata_categories

      rename_cols <- c("codigo_variable" = "codigo")
      x$datos <- NULL
      cbind(
        as_tibble(x),
        tibble(response_categories, response_values),
        data.frame(as.list(response_metadata_values))
      ) |>
        rename(any_of(rename_cols))
    })

    res_content$ficha$filas <- NULL
    res_content$ficha$serie_temporal <- NULL

    rename_cols <- c("codigo_serie" = "codigo")
    question_info <- as_tibble(res_content$ficha) |>
      rename(any_of(rename_cols))

    data <- as_tibble(cbind(question_info, question_data))

    return(data)
  } else {
    stop(sprintf("Error %s in request", res$status_code))
  }
}


#' Flattens the timeseries response from the CIS API.
#'
#' @param res_content A list with the parsed response.
#' @return A data.frame with the parsed response.
#'
#' @importFrom httr content
#' @importFrom tibble as_tibble
#' @importFrom dplyr mutate bind_rows
#' @importFrom purrr map map_df
#'
#' @keywords Internal
#' @noRd
flatten_series <- function(res_content) {

  if(!"series" %in% unique(unlist(map(res_content$lista, names)))) {
    data <- map_df(res_content$lista, bind_rows)
    return(data)
  }

  data <- map_df(res_content$lista, function(x) {

    if(length(x$series) == 0) {
      series <- NULL
    } else if( length(x$series) > 1) {
      series <- map_df(x$series, bind_rows)
    } else {
      series <- x$series[[1]]
    }

    x$series <- NULL

    as_tibble(x) |>
      mutate(series = list(series))
  })

  return(data)
}


#' Searches for the study codes of all the data points of a timeseries.
#'
#' @param series_code A string (or a character vector if more than one) with all the series codes to retrieve data points from.
#' @param since_date A string with the start date of the search in '%d-%m-%Y' format.
#' @param until_date A string with the end date of the search in '%d-%m-%Y' format.
#'
#' @return A data.frame.
#'
#' @importFrom dplyr mutate count select filter
#' @importFrom purrr map_df
#' @importFrom janitor make_clean_names
#' @importFrom rlang .data
#'
#' @keywords Internal
#' @noRd
series_study_codes <- function(series_code, since_date = NULL, until_date = NULL) {

  if(is.null(since_date)) {since_date <- as.Date("1900-01-01")} else {since_date <- as.Date(since_date, "%d-%m-%Y")}
  if(is.null(until_date)) {until_date <- Sys.Date()} else {until_date <- as.Date(until_date, "%d-%m-%Y")}

  data <- map_df(series_code, read_series)

  metadata <-
    data |>
    count(.data$codigo_serie, .data$titulo) |>
    mutate(codigo_serie = make_clean_names(.data$codigo_serie, allow_dupes = T)) |>
    select(-.data$n)

  data <- data |>
    mutate(fecha = as.Date(sprintf("01-%s", .data$fecha), "%d-%m-%Y")) |>
    filter(.data$fecha >= since_date & .data$fecha <= until_date) |>
    count(series_codes = .data$codigo_serie, study_code = .data$estudio,
          study_date = .data$fecha, variable_codes = .data$codigo_variable) |>
    mutate(
      study_code = gsub("/.+", "", .data$study_code),
      series_codes = make_clean_names(.data$series_codes, allow_dupes = T),
      variable_codes = gsub("PA", "A", .data$variable_codes)
    ) |>
    arrange(.data$study_code)

  return(list(data = data, metadata = metadata))
}

#' Searches for the study codes of all the data points of a timeseries.
#'
#' @param studies A data.frame.
#' @param code A string.
#'
#' @return A data.frame.
#'
#' @importFrom dplyr filter select any_of rename mutate across where
#' @importFrom purrr map_chr
#' @importFrom janitor make_clean_names
#' @importFrom haven as_factor is.labelled
#' @importFrom rlang .data
#'
#'
#' @keywords Internal
#' @noRd
series_microdata <- function(studies, code) {
  e <-
    studies |>
    filter(.data$study_code == code)

  variable_codes <- unique(e$variable_codes)
  series_codes <- unique(e$series_codes)
  study_date <- unique(e$study_date)

  tmp <- read_cis(code)

  var_labels <-
    map_chr(tmp, function(x){
      label <- as.character(attr(x, which = "label"))
      if(length(label) > 1 | length(label) == 0) {
        return(NA)
      } else {
        return(label)
      }
    })

  ideol <- names(var_labels[grepl("autoubicaci", tolower(var_labels))])
  sexo <- names(var_labels[grepl("sexo", tolower(var_labels))])
  edad <- names(var_labels[grepl("edad de la persona", tolower(var_labels))])

  cols <- c(sexo, edad, "CCAA", "PROV", "TAMUNI", "ESTUDIOS", ideol, variable_codes)
  rename_cols <- variable_codes
  names(rename_cols) <- series_codes
  rename_cols <- c(rename_cols, "ESCIDEOL" = ideol, "SEXO" = sexo, "EDAD" = edad)
  tryCatch({
    data <- tmp |>
      select(any_of(cols)) |>
      rename(any_of(rename_cols)) |>
      mutate(
        ESTUDIO = as.numeric(code), .before = 1,
        EDAD = as.numeric(.data$EDAD),
        across(where(is.labelled), as_factor)
      )

    return(data)
  }, error = function(e) {
    message(e$message)
  })
}

