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
if (FALSE) { # \dontrun{
# Load a study and inspect its variable dictionary
df <- read_cis("3328")
dict <- get_data_dictionary(df)
print(dict)

# Find variables with a specific keyword in their label
dict[grepl("sexo", dict$label, ignore.case = TRUE), ]

# Inspect value labels for a specific variable
dict$value_labels[[which(dict$variable == "SEXO")]]
} # }
```
