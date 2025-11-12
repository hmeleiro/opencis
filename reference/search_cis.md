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
# Search by search terms
studies <- search_cis(q = "postelectoral")
print(studies)
#> # A tibble: 100 × 4
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
#> # ℹ 90 more rows

# Narrow the search by dates
studies <- search_cis(q = "postelectoral",
                          from = "2011-01-01",
                          to = "2020-01-01")
print(studies)
#> # A tibble: 53 × 4
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
#> # ℹ 43 more rows

# Use the catalogo parameter to search for questions ("pregunta") or data series ("serie")
studies <- search_cis(q = "ideologia",
                          from = "2011-01-01",
                          to = "2020-01-01",
                          catalogo = "serie")
print(studies)
#> # A tibble: 61 × 5
#>    serie               from       to         title                         url  
#>    <chr>               <date>     <date>     <chr>                         <chr>
#>  1 Serie A.3.06.01.053 2010-01-09 2011-11-24 Autodefinición de su ideolog… http…
#>  2 Serie A.4.12.01.004 1993-03-23 2017-09-21 Grado de aceptación en Españ… http…
#>  3 Serie A.3.06.01.027 1997-12-05 2017-11-25 Escala de autoubicación ideo… http…
#>  4 Serie A.3.06.01.056 2006-01-12 2017-09-21 Escala de autoubicación ideo… http…
#>  5 Serie A.3.06.01.036 1987-01-27 2015-03-23 Escala de autoubicación ideo… http…
#>  6 Serie A.3.06.01.031 1987-02-03 2011-03-17 Escala de autoubicación ideo… http…
#>  7 Serie A.3.06.01.035 1986-04-11 2015-03-23 Escala de autoubicación ideo… http…
#>  8 Serie A.3.06.01.026 1997-06-13 2015-02-25 Escala de autoubicación ideo… http…
#>  9 Serie A.3.06.01.033 1987-01-29 2015-09-12 Escala de autoubicación ideo… http…
#> 10 Serie A.4.02.01.165 1992-11-08 2019-10-01 Escala de ubicación ideológi… http…
#> # ℹ 51 more rows
```
