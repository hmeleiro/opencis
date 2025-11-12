# Import a CIS study

Download and import the data of a CIS study.

## Usage

``` r
read_cis(study_code, verbose = FALSE)
```

## Arguments

- study_code:

  A string with the study code.

- verbose:

  boolean. Controls the messages printed on the console.

## Value

A data.frame with the study data.

## Examples

``` r
# If you know the study code you can just read it into R
df <- read_cis("3328")
print(df)
#> # A tibble: 3,206 × 235
#>    ESTUDIO      CUES CCAA      PROV     MUN     CAPITAL TAMUNI  ENTREV  TIPO_TEL
#>    <dbl+lbl>   <dbl> <dbl+lbl> <dbl+lb> <dbl+l> <dbl+l> <dbl+l> <dbl+l> <dbl+lb>
#>  1 3328 [3328]     1 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 2 [Móvi…
#>  2 3328 [3328]     2 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 1 [Fijo]
#>  3 3328 [3328]     3 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 1 [Fijo]
#>  4 3328 [3328]     4 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 1 [Fijo]
#>  5 3328 [3328]     5 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 2 [Móvi…
#>  6 3328 [3328]     6 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 2 [Móvi…
#>  7 3328 [3328]     7 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 2 [Móvi…
#>  8 3328 [3328]     8 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 1 [Fijo]
#>  9 3328 [3328]     9 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 1 [Fijo]
#> 10 3328 [3328]    10 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 2 [Móvi…
#> # ℹ 3,196 more rows
#> # ℹ 226 more variables: SEXO <dbl+lbl>, EDAD <dbl+lbl>, P0 <dbl+lbl>,
#> #   P1 <dbl+lbl>, P1A <dbl+lbl>, P2 <dbl+lbl>, P3 <dbl+lbl>, P4 <dbl+lbl>,
#> #   P5_1 <dbl+lbl>, P5_2 <dbl+lbl>, P5_3 <dbl+lbl>, P5_4 <dbl+lbl>,
#> #   P6 <dbl+lbl>, P6A <dbl+lbl>, P6AR <dbl+lbl>, P6B <dbl+lbl>, P7_1 <dbl+lbl>,
#> #   P7_2 <dbl+lbl>, P7_3 <dbl+lbl>, P7IMPRESA <dbl+lbl>, P7DIGITAL <dbl+lbl>,
#> #   P7TV <dbl+lbl>, P7RADIO <dbl+lbl>, P7A <dbl+lbl>, P7B <dbl+lbl>, …

# If you dont know the study code, you can search for a study using search_cis() function:
studies <- search_cis(q = "gastronomia")
print(studies)
#> # A tibble: 8 × 4
#>   study date       title                                                   url  
#>   <chr> <date>     <chr>                                                   <chr>
#> 1 3419  2023-07-31 Turismo y gastronomía                                   http…
#> 2 3521  2025-09-12 Turismo y gastronomía (III)                             http…
#> 3 3471  2024-07-18 Turismo y gastronomía (II)                              http…
#> 4 1083  1975-07-01 Turismo Viena: estudio multinacional sobre los problem… http…
#> 5 3476  2024-09-20 Cultura y estilos de vida                               http…
#> 6 1200  1979-10-01 Turismo 79                                              http…
#> 7 1481  1985-10-01 Barómetro de la comunidad autónoma de Murcia (II)       http…
#> 8 3505  2025-04-01 Barómetro de abril 2025                                 http…

df <- read_cis(studies$estudio[1])
#> Warning: Unknown or uninitialised column: `estudio`.
#> Error in parse_url(url): length(url) == 1 is not TRUE
print(df)
#> # A tibble: 3,206 × 235
#>    ESTUDIO      CUES CCAA      PROV     MUN     CAPITAL TAMUNI  ENTREV  TIPO_TEL
#>    <dbl+lbl>   <dbl> <dbl+lbl> <dbl+lb> <dbl+l> <dbl+l> <dbl+l> <dbl+l> <dbl+lb>
#>  1 3328 [3328]     1 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 2 [Móvi…
#>  2 3328 [3328]     2 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 1 [Fijo]
#>  3 3328 [3328]     3 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 1 [Fijo]
#>  4 3328 [3328]     4 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 1 [Fijo]
#>  5 3328 [3328]     5 13 [Madr… 28 [Mad… 0 [Mun… 3 [Otr… 2 [2.0… 0 [Ano… 2 [Móvi…
#>  6 3328 [3328]     6 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 2 [Móvi…
#>  7 3328 [3328]     7 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 2 [Móvi…
#>  8 3328 [3328]     8 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 1 [Fijo]
#>  9 3328 [3328]     9 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 1 [Fijo]
#> 10 3328 [3328]    10 13 [Madr… 28 [Mad… 5 [Alc… 3 [Otr… 5 [100… 0 [Ano… 2 [Móvi…
#> # ℹ 3,196 more rows
#> # ℹ 226 more variables: SEXO <dbl+lbl>, EDAD <dbl+lbl>, P0 <dbl+lbl>,
#> #   P1 <dbl+lbl>, P1A <dbl+lbl>, P2 <dbl+lbl>, P3 <dbl+lbl>, P4 <dbl+lbl>,
#> #   P5_1 <dbl+lbl>, P5_2 <dbl+lbl>, P5_3 <dbl+lbl>, P5_4 <dbl+lbl>,
#> #   P6 <dbl+lbl>, P6A <dbl+lbl>, P6AR <dbl+lbl>, P6B <dbl+lbl>, P7_1 <dbl+lbl>,
#> #   P7_2 <dbl+lbl>, P7_3 <dbl+lbl>, P7IMPRESA <dbl+lbl>, P7DIGITAL <dbl+lbl>,
#> #   P7TV <dbl+lbl>, P7RADIO <dbl+lbl>, P7A <dbl+lbl>, P7B <dbl+lbl>, …
```
