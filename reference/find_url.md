# Find CIS study data URL in HTML content

Searches for the URL of the CIS study data ZIP file within the provided
HTML content.

## Usage

``` r
find_url(html, ids = NULL, allow_uuid = FALSE)
```

## Arguments

- html:

  A character string containing the HTML content to search.

- ids:

  An optional vector of two strings representing the numeric subroutes
  of the URL (e.g., c("3411", "3411") for
  "https://www.cis.es/documents/3411/3411/MD3411.zip"). If NULL, the
  function searches for any valid CIS study data URL.

- allow_uuid:

  A boolean indicating whether to allow UUIDs in the URL. Defaults to
  FALSE.

## Value

A character vector of unique URLs found in the HTML content.
