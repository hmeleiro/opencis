# Search all CIS results with automatic pagination

Calls
[`search_cis`](https://opencis.spainelectoralproject.com/reference/search_cis.md)
repeatedly, incrementing the page index until no more results are
returned, and returns all results in a single tibble.

## Usage

``` r
search_all_cis(
  q = "",
  from = NULL,
  to = NULL,
  sort = "relevance",
  catalogo = "estudio",
  ...
)
```

## Arguments

- q:

  String. The search query. Default is an empty string.

- from:

  Date or NULL. The start date for filtering results. Default is NULL.
  The date format must be "YYYY-MM-DD".

- to:

  Date or NULL. The end date for filtering results. Default is NULL. The
  date format must be "YYYY-MM-DD".

- sort:

  String. The sorting order for the results (`"publishDate-"`,
  `"publishDate+"`, `"relevance"`). Default is `"relevance"`.

- catalogo:

  String. The catalog type (`"estudio"`, `"pregunta"`, `"serie"`).
  Default is `"estudio"`.

- ...:

  Additional parameters passed to
  [`search_cis`](https://opencis.spainelectoralproject.com/reference/search_cis.md).

## Value

A tibble with all search results across all pages.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve all postelectoral studies (all pages)
all_studies <- search_all_cis(q = "postelectoral")
print(nrow(all_studies))

# Filter by date range
studies_2010_2020 <- search_all_cis(
  q    = "ideologia",
  from = "2010-01-01",
  to   = "2020-12-31"
)
print(studies_2010_2020)
} # }
```
