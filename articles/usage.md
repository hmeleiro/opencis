# How to use opencis

## Installation

You can install `opencis` from Github using the `devtools` package:

``` r
devtools::install_github("hmeleiro/opencis")
```

## Usage

### Searching for studies, questions and series

[`search_cis()`](https://opencis.spainelectoralproject.com/reference/search_cis.md)
searches the CIS catalogue and returns a tibble with matching results.
The `catalogo` argument controls what type of item is searched:
`"estudio"` (default), `"pregunta"` or `"serie"`. You can restrict
results to a date range with `from` and `to`, and change the sort order
with `sort` (`"relevance"`, `"publishDate-"`, `"publishDate+"`).

``` r
library(opencis)

# Search for survey studies
search_cis(q = "preelectoral", from = "2020-01-01", to = "2023-11-17")

# Search for survey questions
search_cis(q = "feminismo", catalogo = "pregunta")

# Search for data series
search_cis(q = "situación económica", catalogo = "serie")
```

By default
[`search_cis()`](https://opencis.spainelectoralproject.com/reference/search_cis.md)
returns only the first page of results. Use
[`search_all_cis()`](https://opencis.spainelectoralproject.com/reference/search_all_cis.md)
to automatically paginate through all pages and get every matching
result in a single tibble:

``` r
# Retrieve all postelectoral studies (all pages)
all_studies <- search_all_cis(q = "postelectoral")
print(nrow(all_studies))

# Filter by date range across all pages
studies <- search_all_cis(
  q    = "ideologia",
  from = "2010-01-01",
  to   = "2020-12-31"
)
```

[`search_all_cis()`](https://opencis.spainelectoralproject.com/reference/search_all_cis.md)
accepts the same arguments as
[`search_cis()`](https://opencis.spainelectoralproject.com/reference/search_cis.md).

------------------------------------------------------------------------

### Reading study data into R

[`read_cis()`](https://opencis.spainelectoralproject.com/reference/read_cis.md)
downloads the SPSS data file for a study and imports it directly into R
as a labelled data frame (via `haven`):

``` r
df <- read_cis(3411)
print(df)
```

------------------------------------------------------------------------

### Exploring variables: the data dictionary

After loading a study with
[`read_cis()`](https://opencis.spainelectoralproject.com/reference/read_cis.md),
use
[`get_data_dictionary()`](https://opencis.spainelectoralproject.com/reference/get_data_dictionary.md)
to obtain a tidy tibble with every variable name, its label and its
value labels:

``` r
df   <- read_cis(3328)
dict <- get_data_dictionary(df)
print(dict)

# Find variables whose label contains a keyword
dict[grepl("sexo", dict$label, ignore.case = TRUE), ]

# Inspect value labels for a specific variable
dict$value_labels[[which(dict$variable == "SEXO")]]
```

------------------------------------------------------------------------

### Getting study metadata

[`get_metadata()`](https://opencis.spainelectoralproject.com/reference/get_metadata.md)
retrieves the technical information sheet of a study from the CIS
website — field dates, study type, country, authorship, thematic
indices, etc. — and returns it as a two-column tibble (`field`,
`value`):

``` r
meta <- get_metadata(3328)
print(meta)
```

------------------------------------------------------------------------

### Downloading the ZIP file to disk

If you want to keep the raw data files instead of reading them into a
temporary directory, use
[`download_study()`](https://opencis.spainelectoralproject.com/reference/download_study.md).
It saves the ZIP archive to any local folder:

``` r
# Save to the current working directory
path <- download_study(3328)
cat("Saved to:", path, "\n")

# Save to a specific folder
path <- download_study(3328, destdir = "data/raw")
cat("Saved to:", path, "\n")
```

------------------------------------------------------------------------

### Browsing the questionnaire and technical sheet

[`browse_pdf()`](https://opencis.spainelectoralproject.com/reference/browse_pdf.md)
extracts the PDF documents bundled inside the study ZIP and opens them
in your default browser. CIS ZIPs typically include two PDFs:

- **Questionnaire** (`wanted_file = "cues"`, default)
- **Technical sheet** (`wanted_file = "ft"`)

``` r
# Open the questionnaire for study 3328
browse_pdf(3328)

# Open the technical sheet
browse_pdf(3328, wanted_file = "ft")
```
