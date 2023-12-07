# opencis

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/opencis)](https://CRAN.R-project.org/package=opencis)
[![R-CMD-check](https://github.com/hmeleiro/opencis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hmeleiro/opencis/actions/workflows/R-CMD-check.yaml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<!-- badges: end -->

Search and import data directly to R from the Spanish Sociological Research Center (CIS). The CIS is a public institution that conducts electoral and sociological research studies on the Spanish society. The CIS has a large database of surveys that can be accessed through its website. The package includes functions to search for surveys, survey questions and timeseries, and import the data directly to R.

## Installation

You can install `opencis` from Github using the `devtools` package:

``` r
devtools::install_github("hmeleiro/opencis")
```


## Usage

The package includes three group of functions. 

The first group is used to search for surveys, survey questions and timeseries. 

``` r
# Search for survey studies
search_studies(search_terms = "preelectoral", 
               since_date = "01-01-2020", 
               until_date = "17-11-2023")
#> # A tibble: 456 × 4
#>       id codigo titulo                                             fecha     
#>    <int> <chr>  <chr>                                              <date>    
#>  1 14724 3411   PREELECTORAL ELECCIONES GENERALES 2023             2023-06-08
#>  2 14718 3402   PREELECTORAL ELECCIONES MUNICIPALES Y AUTONÓMICAS… 2023-04-10
#>  3 14629 3365   PREELECTORAL ELECCIONES AUTONÓMICAS 2022. COMUNID… 2022-05-17
#>  4 14605 3348   PREELECTORAL ELECCIONES AUTONÓMICAS 2022. COMUNID… 2022-01-07
#>  5 14558 3317   PREELECTORAL ELECCIONES AUTONÓMICAS 2021. COMUNID… 2021-03-19
#>  6 14541 3306   PREELECTORAL DE CATALUÑA. ELECCIONES AUTONÓMICAS … 2021-01-02
#>  7 14513 3286   PREELECTORAL DEL PAÍS VASCO. ELECCIONES AUTONÓMIC… 2020-06-10
#>  8 14514 3287   PREELECTORAL DE GALICIA. ELECCIONES AUTONÓMICAS J… 2020-06-10
#>  9 14491 3275   PREELECTORAL DEL PAÍS VASCO. ELECCIONES AUTONÓMIC… 2020-02-17
#> 10 14492 3276   PREELECTORAL DE GALICIA. ELECCIONES AUTONÓMICAS A… 2020-02-17
#> # ℹ 446 more rows
#> # ℹ Use `print(n = ...)` to see more rows


# Search for survey questions
search_questions(search_terms = "feminismo")
#> # A tibble: 6 × 7
#>       id id_estudio codigo    titulo fecha_estudio titulo_cuestionario series
#>    <int>      <int> <chr>     <chr>  <date>        <chr>               <list>
#> 1 491141      10002 2828/0 0… Rasgo… 2010-01-09    BARÓMETRO DE ENERO… <NULL>
#> 2 485492       1384 2401/0 0… Rasgo… 2000-12-09    25 AÑOS DESPUÉS     <NULL>
#> 3 493678       1202 2212/0 0… Senti… 1996-04-13    BARÓMETRO DE ABRIL… <NULL>
#> 4 479219       1144 2154/0 0… Rasgo… 1995-04-04    CULTURA POLÍTICA (… <NULL>
#> 5 449988       1008 2016/0 0… Rasgo… 1992-07-09    BARÓMETRO DE JULIO… <NULL>
#> 6 452793        985 1993/0 0… Senti… 1992-02-27    BARÓMETRO DE FEBRE… <NULL>

# Search for timeseries
search_series(search_terms = "situación económica")
#> # A tibble: 85 × 6
#>       id variable      titulo                     puntos fecha_minima fecha_maxima
#>    <int> <chr>         <chr>                       <int> <chr>        <chr>       
#>  1  2092 K.1.02.02.002 VALORACIÓN RETROSPECTIVA …    223 10-1978      03-2020     
#>  2  2295 K.1.02.01.003 VALORACIÓN DE LA SITUACIÓ…     21 05-1986      10-2019     
#>  3  2460 K.1.03.02.001 VALORACIÓN PROSPECTIVA DE…    106 04-1995      03-2020     
#>  4  2462 K.1.03.02.003 VALORACIÓN PROSPECTIVA DE…     10 12-1986      02-1999     
#>  5  2463 K.1.03.02.004 VALORACIÓN RETROSPECTIVA …     15 04-1992      01-2011     
#>  6  2464 K.1.03.01.001 VALORACIÓN DE LA SITUACIÓ…    118 04-1992      03-2020     
#>  7  2467 K.1.03.02.005 VALORACIÓN RETROSPECTIVA …     11 02-1992      02-1999     
#>  8  2469 K.1.03.02.008 VALORACIÓN PROSPECTIVA DE…      6 05-2001      11-2017     
#>  9  3075 K.1.02.01.001 VALORACIÓN DE LA SITUACIÓ…    364 06-1979      03-2020     
#> 10  3076 K.1.02.02.001 VALORACIÓN PROSPECTIVA DE…    344 10-1978      03-2020     
#> # ℹ 75 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

The second group of functions retrieves the valid category codes to narrow search queries. [Read the documentation](https://hmeleiro.github.io/opencis/reference/index.html#retrieve-categories) to understand how to use the category codes in the search functions.

``` r
get_study_categories()
#> # A tibble: 213 × 4
#>       id conteo codigo      titulo                              
#>    <int>  <int> <chr>       <chr>                               
#>  1     1   1356 001         POLÍTICA                            
#>  2     1     24 001_000     Política                            
#>  3     2    222 001_001     Estado, Constitución e instituciones
#>  4     2     94 001_001_000 Estado, constitución e instituciones
#>  5   210     56 001_001_001 Constitución                        
#>  6     4     29 001_001_002 Fuerzas Armadas y defensa           
#>  7     3     66 001_001_003 Gobierno                            
#>  8   551     22 001_001_004 Monarquía                           
#>  9     5    197 001_002     Administración y servicios públicos 
#> 10     6    301 001_003     Cultura política                    
#> # ℹ 203 more rows
#> # ℹ Use `print(n = ...)` to see more rows

get_question_categories()
#> # A tibble: 5,257 × 4
#>       id conteo codigo              titulo                  
#>    <int>  <int> <chr>               <chr>                   
#>  1  1637 154084 003                 DESCRIPTORES            
#>  2     1   1699 003_001             Ciencia                 
#>  3     1     92 003_001_000         Ciencia                 
#>  4     2     16 003_001_001         Ciencia espacial        
#>  5     3    117 003_001_002         Desarrollo científico   
#>  6     4    599 003_001_003         Investigación científica
#>  7     4    122 003_001_003_000     Investigación científica
#>  8     5    402 003_001_003_001     Métodos de investigación
#>  9     6    402 003_001_003_001_001 Encuestas               
#> 10     7     23 003_001_003_001_002 Trabajo de campo        
#> # ℹ 5,247 more rows
#> # ℹ Use `print(n = ...)` to see more rows

get_series_category()
#> # A tibble: 4,433 × 6
#>     dmid conteo dmvariable    dmtitulo                        dmprquestion dmindex
#>    <int>  <int> <chr>         <chr>                           <chr>        <chr>  
#>  1   235   1190 A             ESTADO, SISTEMA POLÍTICO        ""           001    
#>  2   221     92 A.1           CONSTITUCIÓN E INSTITUCIONES    ""           001_001
#>  3   222     24 A.1.01        CONSTITUCIÓN                    ""           001_00…
#>  4   223      6 A.1.01.01     CONOCIMIENTO DE LA CONSTITUCIÓN ""           001_00…
#>  5  2535      1 A.1.01.01.001 GRADO DE CONOCIMIENTO DE LA CO… "<p style=\… 001_00…
#>  6  2977      1 A.1.01.01.002 GRADO DE CONOCIMIENTO DE LA CO… "<p style=\… 001_00…
#>  7  2978      1 A.1.01.01.004 GRADO DE ESFUERZO DE LOS GOBIE… "<p style=\… 001_00…
#>  8 16109      1 A.1.01.01.009 ACUERDO CON DISTINTOS MEDIOS D… "<p style=\… 001_00…
#>  9 16110      1 A.1.01.01.010 ACUERDO CON DISTINTOS MEDIOS D… "<p style=\… 001_00…
#> 10 16112      1 A.1.01.01.011 ACUERDO CON DISTINTOS MEDIOS D… "<p style=\… 001_00…
#> # ℹ 4,423 more rows
#> # ℹ Use `print(n = ...)` to see more rows

```


The third group of functions are used to import the data directly into R. 

``` r
# Read a survey study
df <- read_cis("3411")
#> probando la URL 'https://www.cis.es/documents/d/cis/MD3411'
#> Content type 'application/zip' length 14194752 bytes (13.5 MB)
#> downloaded 13.5 MB
print(df)
#> Invalid date string (length=9): 11 042 23
#> # A tibble: 29,201 × 216
#>    ESTUDIO     REGISTRO  CUES CCAA         PROV    MUN     CAPITAL TAMUNI  ENTREV 
#>    <dbl+lbl>      <dbl> <dbl> <dbl+lbl>    <dbl+l> <dbl+l> <dbl+l> <dbl+l> <dbl+l>
#>  1 3411 [3411]   492777 29043 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 1 [Men… 0 [Ano…
#>  2 3411 [3411]    70655  5848 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 1 [Men… 0 [Ano…
#>  3 3411 [3411]    46423  3893 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 3 [10.… 0 [Ano…
#>  4 3411 [3411]   103464  8711 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 3 [10.… 0 [Ano…
#>  5 3411 [3411]   112810  9517 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 3 [10.… 0 [Ano…
#>  6 3411 [3411]   126567 10736 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 3 [10.… 0 [Ano…
#>  7 3411 [3411]   137692 11573 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 3 [10.… 0 [Ano…
#>  8 3411 [3411]   182178 14839 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 3 [10.… 0 [Ano…
#>  9 3411 [3411]   216764 16793 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 3 [10.… 0 [Ano…
#> 10 3411 [3411]   237655 17918 1 [Andalucí… 4 [Alm… 0 [Mun… 3 [Otr… 3 [10.… 0 [Ano…
#> # ℹ 29,191 more rows
#> # ℹ 207 more variables: TIPO_TEL <dbl+lbl>, SEXO <dbl+lbl>, EDAD <dbl+lbl>,
#> #   P0A <dbl+lbl>, ECOPER <dbl+lbl>, ECOESP <dbl+lbl>, MEDIO_1 <dbl+lbl>,
#> #   MEDIO_2 <dbl+lbl>, LEEPRENSA <dbl+lbl>, VETELE <dbl+lbl>, OYERADIO <dbl+lbl>,
#> #   PRENSA <dbl+lbl>, P3AR <dbl+lbl>, TELEVISION <dbl+lbl>, P3BR <dbl+lbl>,
#> #   RADIO <dbl+lbl>, P3CR <dbl+lbl>, GESTIONGOB <dbl+lbl>, GESTIONOPO <dbl+lbl>,
#> #   PROBVOTO <dbl+lbl>, VOTOCORREO <dbl+lbl>, PROBPARTIDOS_1 <dbl+lbl>, …
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names

# Read a timeseries
df_series <- read_series("2092")
print(df_series)
#> # A tibble: 1,115 × 16
#>       id codigo_serie  titulo   pregunta muestra notas multiVariable estudio fecha
#>    <int> <chr>         <chr>    <chr>    <chr>   <chr> <lgl>         <chr>   <chr>
#>  1  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1169/1  10-1…
#>  2  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1169/1  10-1…
#>  3  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1169/1  10-1…
#>  4  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1169/1  10-1…
#>  5  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1169/1  10-1…
#>  6  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1189/0  06-1…
#>  7  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1189/0  06-1…
#>  8  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1189/0  06-1…
#>  9  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1189/0  06-1…
#> 10  2092 K.1.02.02.002 VALORAC… "<p sty… Nacion… ""    FALSE         1189/0  06-1…
#> # ℹ 1,105 more rows
#> # ℹ 7 more variables: codigo_variable <chr>, idEstudio <chr>, idPregunta <chr>,
#> #   idVariable <chr>, response_categories <chr>, response_values <dbl>,
#> #   X.N. <dbl>
#> # ℹ Use `print(n = ...)` to see more rows
```


## SSL certificate error on Ubuntu
Due to an issue with the SSL certificate of CIS website the following error may be thrown on Ubuntu systems:
```
SSL peer certificate or SSH remote key was not OK: [www.cis.es] SSL certificate problem: unable to get local issuer certificate
```

To solve this problem the user must disable the SSL peer verification option. To do so the following command must be run once in each session:

```
httr::set_config(httr::config(ssl_verifypeer = 0L))
```

I understand that disabling the SSL peer verification option is not ideal as it may be a security risk, but this is not an `opencis` issue, it's a problem on the CIS end side. It has to do with the security certificate presented by the CIS website not been issued by a trusted certificate authority.
