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
if (FALSE) { # \dontrun{
# Get metadata for study 3328
meta <- get_metadata("3328")
print(meta)

# Access a specific field
meta$value[meta$field == "Tipo de estudio"]
} # }
```
