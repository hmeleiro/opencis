# Search for CIS studies.

Searches for CIS studies using the CIS search engine.

## Usage

``` r
search_cis(
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

  Date or NULL. The start date for filtering results. Default is NULL.
  The date format must be "YYYY-MM-DD".

- to:

  Date or NULL. The end date for filtering results. Default is NULL. The
  date format must be "YYYY-MM-DD".

- sort:

  String. The sorting order for the results ("publishDate-",
  "publishDate+", "relevance"). Default is "relevance".

- catalogo:

  String. The catalog type ("estudio", "pregunta", "serie"). Default is
  "estudio".

- ...:

  Additional parameters (not used).

## Value

A data.frame with the search results.

## Examples

``` r
if (FALSE) { # \dontrun{
# Search by search terms
studies <- search_cis(q = "postelectoral")
print(studies)

# Narrow the search by dates
studies <- search_cis(q = "postelectoral",
                          from = "2011-01-01",
                          to = "2020-01-01")
print(studies)

# Use the catalogo parameter to search for questions ("pregunta") or data series ("serie")
studies <- search_cis(q = "ideologia",
                          from = "2011-01-01",
                          to = "2020-01-01",
                          catalogo = "serie")
print(studies)
} # }
```
