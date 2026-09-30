# How to use opencis

## Installation

You can install the released version of `opencis` from CRAN:

``` r

install.packages("opencis")
```

You can install the development version from GitHub using the `remotes`
package:

``` r

remotes::install_github("hmeleiro/opencis")
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

#### Advanced search

The `q` argument accepts the [advanced Lucene syntax supported by the
CIS catalog](https://www.cis.es/es/estudios/catalogo). An advanced
expression must start with `*`. Pass the expression as plain text;
`opencis` handles URL encoding.

``` r

# Match any of several study codes
search_cis(q = "*surveyCode:(2610 OR 2829 OR 2956)")

# Require barometro and 2024 in the title, but exclude sanitario
search_cis(q = "*title_es_ES:(+barometro +2024 -sanitario)")

# Search question text and retrieve every result page
search_all_cis(
  q = "*question_es_ES:(divorcio)",
  catalogo = "pregunta"
)

# Combine fields: questions about divorce from studies after number 3540
search_all_cis(
  q = "*question_es_ES:(divorcio) AND surveyCodeNumber:{3540 TO *]",
  catalogo = "pregunta"
)

# Search for an exact phrase
search_cis(q = '*title_es_ES:"barómetro de la vivienda"')

# Search a numeric study-code range (used in the CIS documentation)
search_cis(q = "*(surveyCodeNumber:[3000 TO 3002])")
```

The CIS documents the following searchable fields. Catalog data are
currently indexed only in Spanish (`es_ES`).

| Field                  | Indexing | Contents                                   |
|:-----------------------|:---------|:-------------------------------------------|
| `surveyCode`           | keyword  | Study code                                 |
| `questionCode`         | keyword  | Question code                              |
| `serieCode`            | keyword  | Series code                                |
| `title_es_ES`          | text     | Study, question, or series title           |
| `description_es_ES`    | text     | Study or series description                |
| `publishDate`          | text     | Study/question date, or latest series date |
| `question_es_ES`       | text     | Study question wording                     |
| `questionText_es_ES`   | text     | Study question text                        |
| `descriptors_es_ES`    | text     | Question descriptors                       |
| `collections_es_ES`    | text     | Study collection names                     |
| `publications_es_ES`   | text     | Study publication names                    |
| `subjectIndexes_es_ES` | text     | Study subject indexes                      |
| `orders_es_ES`         | text     | Study commissioners                        |
| `authors_es_ES`        | text     | Study authors                              |

The CIS also uses `surveyCodeNumber` in its numeric-range example,
although it is not included in the site’s field table. Treat that field
as server-specific and potentially less stable than the documented list.

Lucene expressions can combine `AND`, `OR`, required terms (`+`),
excluded terms (`-`), quoted phrases, ranges, and term boosting with
`^`. Invalid syntax may return no results. Advanced searches also use a
different relevance order from simple searches and do not highlight
matches.

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
