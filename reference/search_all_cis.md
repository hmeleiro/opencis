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
  ...,
  start = 1
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

- start:

  Integer. First page to retrieve, default 1. Use the returned
  `next_page` attribute to resume an interrupted search with the same
  filters.

## Value

A tibble with search results and a logical `complete` attribute. On HTTP
failure, warns and returns the collected rows with `complete = FALSE`
and a `next_page` attribute for resuming.

## Details

Network GET requests are spaced by at least one second per origin within
the R session. Configure this with
`options(opencis.request_interval = 2)` (seconds). HTTP 429 responses
are retried up to five times, respecting `Retry-After` or using
exponential backoff with jitter (up to 60 seconds). Set
`options(opencis.max_retries = 8)` to change the retry limit; zero
disables retries. Cached responses do not wait or use the network.
Resuming retrieves only the remaining pages; combine them with the saved
rows. Page positions may change if the remote catalog changes between
calls.

## Examples

``` r
if (interactive()) {
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
}
```
