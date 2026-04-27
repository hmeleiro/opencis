cis_request_timeout <- function() {
    timeout <- getOption("opencis.timeout", 20)
    timeout <- suppressWarnings(as.numeric(timeout))
    if (is.na(timeout) || timeout <= 0) {
        return(20)
    }
    timeout
}

cis_user_agent <- function() {
    paste0("opencis/", utils::packageVersion("opencis"))
}

cis_get <- function(url, ..., required = FALSE, context = "request") {
    resp <- tryCatch(
        GET(
            url,
            httr::timeout(cis_request_timeout()),
            httr::user_agent(cis_user_agent()),
            ...
        ),
        error = function(e) {
            if (required) {
                stop(sprintf("Failed %s for '%s': %s", context, url, conditionMessage(e)), call. = FALSE)
            }
            warning(sprintf("Failed %s for '%s': %s", context, url, conditionMessage(e)), call. = FALSE)
            NULL
        }
    )

    if (is.null(resp)) {
        return(NULL)
    }

    status <- status_code(resp)
    if (status >= 400) {
        msg <- sprintf("HTTP %s while %s for '%s'.", status, context, url)
        if (required) {
            stop(msg, call. = FALSE)
        }
        warning(msg, call. = FALSE)
        return(NULL)
    }

    resp
}
