# Build CIS catalog URL with date range

Constructs a URL for querying the CIS catalog with optional date range
filters.

## Usage

``` r
cis_catalog_url_date(
  start = 1,
  q = "",
  from = NULL,
  to = NULL,
  sort = "relevance",
  catalogo = "estudio",
  ...
)
```

## Arguments

- start:

  Integer. The starting page for the search results. Default is 1,
  iterate to get more results.

- q:

  String. The search query. Default is an empty string.

- from:

  Date or NULL. The start date for filtering results. Default is NULL

- to:

  Date or NULL. The end date for filtering results. Default is NULL.

- sort:

  String. The sorting order for the results ("publishDate-",
  "publishDate+", "relevance"). Default is "relevance".

- catalogo:

  String. The catalog type ("estudio", "pregunta", "serie"). Default is
  "estudio".

- ...:

  Additional parameters (not used).

## Value

A string representing the constructed URL.
