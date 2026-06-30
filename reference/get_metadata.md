# Get metadata of a CIS study

Retrieves the technical metadata of a CIS study from its detail page,
including study dates, type, country, author, and thematic indices.

## Usage

``` r
get_metadata(study_code)
```

## Arguments

- study_code:

  A string with the study code.

## Value

A tibble with two columns: `field` and `value`.

## Examples

``` r
# \donttest{
# Get metadata for study 3328
meta <- get_metadata("3328")
print(meta)
#> # A tibble: 9 × 2
#>   field             value                                                       
#>   <chr>             <chr>                                                       
#> 1 Fecha de estudio  "18/06/2021"                                                
#> 2 Código            "3328"                                                      
#> 3 Tipo de estudio   "Cuantitativo"                                              
#> 4 País              "España"                                                    
#> 5 Autor             "CIS"                                                       
#> 6 Encargo           "CIS"                                                       
#> 7 Colecciones       "Ver (2)"                                                   
#> 8 Índices temáticos "Cultura política; Partidos y líderes políticos; Elecciones…
#> 9 Publicación       "FUERA DE COLECCIÓN CIS -\n                                …

# Access a specific field
meta$value[meta$field == "Tipo de estudio"]
#> [1] "Cuantitativo"
# }
```
