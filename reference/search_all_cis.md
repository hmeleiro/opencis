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
# \donttest{
# Retrieve all postelectoral studies (all pages)
all_studies <- search_all_cis(q = "postelectoral")
print(nrow(all_studies))
#> [1] 191

# Filter by date range
studies_2010_2020 <- search_all_cis(
  q    = "ideologia",
  from = "2010-01-01",
  to   = "2020-12-31"
)
print(studies_2010_2020)
#> # A tibble: 163 × 4
#>    study date       title                                                  url  
#>    <chr> <date>     <chr>                                                  <chr>
#>  1 2930  2012-01-20 Congruencia ideológica entre electores y representant… http…
#>  2 3257  2019-07-01 Barómetro de julio 2019                                http…
#>  3 3082  2015-05-01 Barómetro de mayo 2015                                 http…
#>  4 2938  2012-03-21 Actitudes de la juventud en España hacia el emprendim… http…
#>  5 3150  2016-09-12 Percepción de la discriminación en España (II)         http…
#>  6 2847  2010-10-04 Barómetro de octubre 2010                              http…
#>  7 2967  2012-10-31 Actitudes hacia la inmigración (VI)                    http…
#>  8 3119  2015-11-19 Actitudes hacia la inmigración (VIII)                  http…
#>  9 2918  2011-11-05 Actitudes hacia la inmigración (V)                     http…
#> 10 2846  2010-09-21 Actitudes hacia la inmigración (IV)                    http…
#> # ℹ 153 more rows
# }
```
