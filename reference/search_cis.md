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
# \donttest{
# Search by search terms
studies <- search_cis(q = "postelectoral")
print(studies)
#> # A tibble: 50 × 4
#>    study date       title                                   url                 
#>    <chr> <date>     <chr>                                   <chr>               
#>  1 1497  1985-12-01 Postelectoral Galicia 1985              https://www.cis.es/…
#>  2 1292  1981-11-03 Postelectoral Galicia 1981              https://www.cis.es/…
#>  3 2199  1995-11-28 Postelectoral Cataluña 1995             https://www.cis.es/…
#>  4 1998  1992-03-25 Postelectoral Cataluña 1992             https://www.cis.es/…
#>  5 1750  1988-06-02 Postelectoral Cataluña 1988             https://www.cis.es/…
#>  6 1903  1990-11-08 Postelectoral País Vasco 1990           https://www.cis.es/…
#>  7 1402  1984-03-01 Postelectoral País Vasco 1984           https://www.cis.es/…
#>  8 2120  1994-10-28 Postelectoral País Vasco 1994           https://www.cis.es/…
#>  9 1565  1986-12-01 Postelectoral País Vasco 1986           https://www.cis.es/…
#> 10 1327  1982-11-01 Postelectoral elecciones generales 1982 https://www.cis.es/…
#> # ℹ 40 more rows

# Narrow the search by dates
studies <- search_cis(q = "postelectoral",
                          from = "2011-01-01",
                          to = "2020-01-01")
print(studies)
#> # A tibble: 50 × 4
#>    study date       title                                                  url  
#>    <chr> <date>     <chr>                                                  <chr>
#>  1 3248  2019-05-10 Postelectoral elecciones generales 2019                http…
#>  2 3145  2016-07-04 Postelectoral elecciones generales 2016                http…
#>  3 2890  2011-05-27 Postelectoral elecciones municipales 2011. Barcelona   http…
#>  4 3085  2015-05-31 Postelectoral elecciones municipales 2015. Barcelona   http…
#>  5 3155  2016-09-28 Postelectoral de Galicia. Elecciones autonómicas 2016  http…
#>  6 3202  2017-12-28 Postelectoral de Cataluña. Elecciones autonómicas 2017 http…
#>  7 3113  2015-09-30 Postelectoral de Cataluña. Elecciones autonómicas 2015 http…
#>  8 3028  2014-05-29 Postelectoral elecciones al Parlamento Europeo 2014    http…
#>  9 2963  2012-10-25 Postelectoral de Galicia. Elecciones autonómicas 2012  http…
#> 10 3253  2019-06-17 Postelectoral elecciones autonómicas y municipales 20… http…
#> # ℹ 40 more rows

# Use the catalogo parameter to search for questions ("pregunta") or data series ("serie")
studies <- search_cis(q = "ideologia",
                          from = "2011-01-01",
                          to = "2020-01-01",
                          catalogo = "serie")
print(studies)
#> # A tibble: 0 × 2
#> # ℹ 2 variables: title <chr>, url <chr>
# }
```
