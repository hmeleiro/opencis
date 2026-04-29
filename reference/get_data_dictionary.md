# Extract a data dictionary from a CIS study data frame

Returns a tibble listing each variable in the data along with its
variable label and value labels, as loaded by `haven`.

## Usage

``` r
get_data_dictionary(data)
```

## Arguments

- data:

  A data.frame loaded from a CIS `.sav` file, typically the output of
  [`read_cis`](https://opencis.spainelectoralproject.com/reference/read_cis.md).

## Value

A tibble with columns:

- variable:

  Variable name.

- label:

  Variable label, or `NA` if none.

- value_labels:

  A named numeric vector of value labels, or `NULL` for unlabelled
  variables (list-column).

## Examples

``` r
# Create a small labelled data frame
df <- data.frame(
  SEXO = haven::labelled(c(1, 2, 1), labels = c(Hombre = 1, Mujer = 2)),
  EDAD = c(34, 51, 29)
)
attr(df$SEXO, "label") <- "Sexo"
attr(df$EDAD, "label") <- "Edad"

# Inspect its variable dictionary
dict <- get_data_dictionary(df)
print(dict)
#> # A tibble: 2 × 3
#>   variable label value_labels
#>   <chr>    <chr> <named list>
#> 1 SEXO     Sexo  <dbl [2]>   
#> 2 EDAD     Edad  <NULL>      

# Find variables with a specific keyword in their label
dict[grepl("sexo", dict$label, ignore.case = TRUE), ]
#> # A tibble: 1 × 3
#>   variable label value_labels
#>   <chr>    <chr> <named list>
#> 1 SEXO     Sexo  <dbl [2]>   

# Inspect value labels for a specific variable
sex_var <- match("SEXO", dict$variable)
if (!is.na(sex_var)) {
  dict$value_labels[[sex_var]]
}
#> Hombre  Mujer 
#>      1      2 
```
