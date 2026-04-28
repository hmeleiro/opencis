# Import a CIS study

Download and import the data of a CIS study.

## Usage

``` r
read_cis(study_code)
```

## Arguments

- study_code:

  A string with the study code.

## Value

A data.frame with the study data.

## Examples

``` r
if (FALSE) { # \dontrun{
# If you know the study code you can just read it into R
df <- read_cis("3328")
print(df)

# If you dont know the study code, you can search for a study using search_cis() function:
studies <- search_cis(q = "gastronomia")
print(studies)

df <- read_cis(studies$study[1])
print(df)
} # }
```
