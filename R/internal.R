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
#' @importFrom dplyr rename mutate
#' @importFrom rlang .data
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
      rename(any_of(rename_cols)) |>
      mutate(pregunta = clean_html_tags(.data$pregunta))

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

#' Removes html tags from a string.
#'
#' @param str A string.
#'
#' @return A string.
#'
#' @importFrom stats setNames
#' @importFrom gsubfn gsubfn
#'
#' @keywords Internal
#' @noRd
clean_html_tags <- function(str) {
  htmlchars <- setNames(
    c("\u0022", "\u0026", "\u0027", "\u003C", "\u003E", "\u00A0", "\u00A1", "\u00A2", "\u00A3", "\u00A4", "\u00A5", "\u00A6", "\u00A7", "\u00A8", "\u00A9", "\u00AA", "\u00AB", "\u00AC", "\u00AD", "\u00AE", "\u00AF", "\u00B0", "\u00B1", "\u00B2", "\u00B3", "\u00B4", "\u00B5", "\u00B6", "\u00B7", "\u00B8", "\u00B9", "\u00BA", "\u00BB", "\u00BC", "\u00BD", "\u00BE", "\u00BF", "\u00C0", "\u00C1", "\u00C2", "\u00C3", "\u00C4", "\u00C5", "\u00C6", "\u00C7", "\u00C8", "\u00C9", "\u00CA", "\u00CB", "\u00CC", "\u00CD", "\u00CE", "\u00CF", "\u00D0", "\u00D1", "\u00D2", "\u00D3", "\u00D4", "\u00D5", "\u00D6", "\u00D7", "\u00D8", "\u00D9", "\u00DA", "\u00DB", "\u00DC", "\u00DD", "\u00DE", "\u00DF", "\u00E0", "\u00E1", "\u00E2", "\u00E3", "\u00E4", "\u00E5", "\u00E6", "\u00E7", "\u00E8", "\u00E9", "\u00EA", "\u00EB", "\u00EC", "\u00ED", "\u00EE", "\u00EF", "\u00F0", "\u00F1", "\u00F2", "\u00F3", "\u00F4", "\u00F5", "\u00F6", "\u00F7", "\u00F8", "\u00F9", "\u00FA", "\u00FB", "\u00FC", "\u00FD", "\u00FE", "\u00FF", "\u0152", "\u0153", "\u0160", "\u0161", "\u0178", "\u0192", "\u02C6", "\u02DC", "\u0391", "\u0392", "\u0393", "\u0394", "\u0395", "\u0396", "\u0397", "\u0398", "\u0399", "\u039A", "\u039B", "\u039C", "\u039D", "\u039E", "\u039F", "\u03A0", "\u03A1", "\u03A3", "\u03A4", "\u03A5", "\u03A6", "\u03A7", "\u03A8", "\u03A9", "\u03B1", "\u03B2", "\u03B3", "\u03B4", "\u03B5", "\u03B6", "\u03B7", "\u03B8", "\u03B9", "\u03BA", "\u03BB", "\u03BC", "\u03BD", "\u03BE", "\u03BF", "\u03C0", "\u03C1", "\u03C2", "\u03C3", "\u03C4", "\u03C5", "\u03C6", "\u03C7", "\u03C8", "\u03C9", "\u03D1", "\u03D2", "\u03D6", "\u2002", "\u2003", "\u2009", "\u200C", "\u200D", "\u200E", "\u200F", "\u2013", "\u2014", "\u2018", "\u2019", "\u201A", "\u201C", "\u201D", "\u201E", "\u2020", "\u2021", "\u2022", "\u2026", "\u2030", "\u2032", "\u2033", "\u2039", "\u203A", "\u203E", "\u2044", "\u20AC", "\u2111", "\u2118", "\u211C", "\u2122", "\u2135", "\u2190", "\u2191", "\u2192", "\u2193", "\u2194", "\u21B5", "\u21D0", "\u21D1", "\u21D2", "\u21D3", "\u21D4", "\u2200", "\u2202", "\u2203", "\u2205", "\u2207", "\u2208", "\u2209", "\u220B", "\u220F", "\u2211", "\u2212", "\u2217", "\u221A", "\u221D", "\u221E", "\u2220", "\u2227", "\u2228", "\u2229", "\u222A", "\u222B", "\u2234", "\u223C", "\u2245", "\u2248", "\u2260", "\u2261", "\u2264", "\u2265", "\u2282", "\u2283", "\u2284", "\u2286", "\u2287", "\u2295", "\u2297", "\u22A5", "\u22C5", "\u22EE", "\u2308", "\u2309", "\u230A", "\u230B", "\u2329", "\u232A", "\u25CA", "\u2660", "\u2663", "\u2665"),
    c("quot", "amp", "apos", "lt", "gt", "nbsp", "iexcl", "cent", "pound", "curren", "yen", "brvbar", "sect", "uml", "copy", "ordf", "laquo", "not", "shy", "reg", "macr", "deg", "plusmn", "sup2", "sup3", "acute", "micro", "para", "middot", "cedil", "sup1", "ordm", "raquo", "frac14", "frac12", "frac34", "iquest", "Agrave", "Aacute", "Acirc", "Atilde", "Auml", "Aring", "AElig", "Ccedil", "Egrave", "Eacute", "Ecirc", "Euml", "Igrave", "Iacute", "Icirc", "Iuml", "ETH", "Ntilde", "Ograve", "Oacute", "Ocirc", "Otilde", "Ouml", "times", "Oslash", "Ugrave", "Uacute", "Ucirc", "Uuml", "Yacute", "THORN", "szlig", "agrave", "aacute", "acirc", "atilde", "auml", "aring", "aelig", "ccedil", "egrave", "eacute", "ecirc", "euml", "igrave", "iacute", "icirc", "iuml", "eth", "ntilde", "ograve", "oacute", "ocirc", "otilde", "ouml", "divide", "oslash", "ugrave", "uacute", "ucirc", "uuml", "yacute", "thorn", "yuml", "OElig", "oelig", "Scaron", "scaron", "Yuml", "fnof", "circ", "tilde", "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega", "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigmaf", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega", "thetasym", "upsih", "piv", "ensp", "emsp", "thinsp", "zwnj", "zwj", "lrm", "rlm", "ndash", "mdash", "lsquo", "rsquo", "sbquo", "ldquo", "rdquo", "bdquo", "dagger", "Dagger", "bull", "hellip", "permil", "prime", "Prime", "lsaquo", "rsaquo", "oline", "frasl", "euro", "image", "weierp", "real", "trade", "alefsym", "larr", "uarr", "rarr", "darr", "harr", "crarr", "lArr", "uArr", "rArr", "dArr", "hArr", "forall", "part", "exist", "empty", "nabla", "isin", "notin", "ni", "prod", "sum", "minus", "lowast", "radic", "prop", "infin", "ang", "and", "or", "cap", "cup", "int", "there4", "sim", "cong", "asymp", "ne", "equiv", "le", "ge", "sub", "sup", "nsub", "sube", "supe", "oplus", "otimes", "perp", "sdot", "vellip", "lceil", "rceil", "lfloor", "rfloor", "lang", "rang", "loz", "spades", "clubs", "hearts")
  )
  str <- gsub("<.*?>", "", str)
  ret <- gsubfn("&#([0-9]+);", function(x) rawToChar(as.raw(as.numeric(x))), str)
  ret <- gsubfn("&([^;]+);", function(x) htmlchars[x], ret)
  ret <- gsub('\\"', "'", ret)
  ret <- gsub('\r|\n', "", ret)
  return(ret)
}

