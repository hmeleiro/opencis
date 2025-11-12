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

df <- read_cis(studies$study[1])
#> Invalid date string (length=9): 22 038 23
print(df)
#> # A tibble: 4,538 × 176
#>    ESTUDIO     REGISTRO  CUES CCAA      PROV    MUN      CAPITAL ENTREV  TAMUNI 
#>    <dbl+lbl>      <dbl> <dbl> <dbl+lbl> <dbl+l> <dbl+lb> <dbl+l> <dbl+l> <dbl+l>
#>  1 3419 [3419]     7593   356 1 [Andal… 4 [Alm…  0 [Mun… 3 [Otr… 0 [Ano… 3 [10.…
#>  2 3419 [3419]   123740  4382 1 [Andal… 4 [Alm…  0 [Mun… 3 [Otr… 0 [Ano… 3 [10.…
#>  3 3419 [3419]   128945  4445 1 [Andal… 4 [Alm…  0 [Mun… 3 [Otr… 0 [Ano… 3 [10.…
#>  4 3419 [3419]    10347   505 1 [Andal… 4 [Alm…  0 [Mun… 3 [Otr… 0 [Ano… 3 [10.…
#>  5 3419 [3419]     4465   207 1 [Andal… 4 [Alm… 13 [Alm… 2 [Cap… 0 [Ano… 5 [100…
#>  6 3419 [3419]     5939   270 1 [Andal… 4 [Alm… 13 [Alm… 2 [Cap… 0 [Ano… 5 [100…
#>  7 3419 [3419]     8237   388 1 [Andal… 4 [Alm… 13 [Alm… 2 [Cap… 0 [Ano… 5 [100…
#>  8 3419 [3419]    14249   706 1 [Andal… 4 [Alm… 13 [Alm… 2 [Cap… 0 [Ano… 5 [100…
#>  9 3419 [3419]    16041   797 1 [Andal… 4 [Alm… 13 [Alm… 2 [Cap… 0 [Ano… 5 [100…
#> 10 3419 [3419]    17774   878 1 [Andal… 4 [Alm… 13 [Alm… 2 [Cap… 0 [Ano… 5 [100…
#> # ℹ 4,528 more rows
#> # ℹ 167 more variables: TIPO_TEL <dbl+lbl>, SEXO <dbl+lbl>, EDAD <dbl+lbl>,
#> #   P0 <dbl+lbl>, P1 <dbl+lbl>, P1A <dbl+lbl>, P1B <dbl+lbl>, P1C_1 <dbl+lbl>,
#> #   P1C_2 <dbl+lbl>, P1C_3 <dbl+lbl>, P1C_4 <dbl+lbl>, P1C_5 <dbl+lbl>,
#> #   P1C_6 <dbl+lbl>, P1C_7 <dbl+lbl>, P1C_98 <dbl+lbl>, P1C_99 <dbl+lbl>,
#> #   P1D <dbl+lbl>, P1E <dbl+lbl>, P2 <dbl+lbl>, P3 <dbl+lbl>, P3_1 <dbl+lbl>,
#> #   P4 <dbl+lbl>, P5 <dbl+lbl>, EMPLEO_1_1 <dbl+lbl>, EMPLEO_1_2 <dbl+lbl>, …
```
