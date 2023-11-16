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

    x <- res_content$ficha$serie_temporal[[1]]

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
