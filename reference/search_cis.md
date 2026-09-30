# Search for CIS studies.

Searches for CIS studies using the CIS search engine.

## Usage

``` r
search_cis(
  start = 1,
  q = "",
  from = NULL,
  to = NULL,
  sort = "relevance",
  catalogo = "estudio",
  ...
)
```

## Arguments

- start:

  Integer. The starting page for the search results. Default is 1,
  iterate to get more results.

- q:

  A single character string containing a simple search or an advanced
  Lucene query. Advanced queries must start with `*`; pass them as plain
  text because URL encoding is handled by the package. Default is an
  empty string.

- from:

  Date or NULL. The start date for filtering results. Default is NULL.
  The date format must be "YYYY-MM-DD".

- to:

  Date or NULL. The end date for filtering results. Default is NULL. The
  date format must be "YYYY-MM-DD".

- sort:

  String. The sorting order for the results ("publishDate-",
  "publishDate+", "relevance"). Default is "relevance".

- catalogo:

  String. The catalog type ("estudio", "pregunta", "serie"). Default is
  "estudio".

- ...:

  Additional parameters (not used).

## Value

A data.frame with the search results.

## Details

The CIS catalog supports advanced Lucene queries when `q` starts with
`*`. These queries can use Boolean operators, exact phrases, exclusions,
ranges, term boosting, and field-specific searches. For example,
`*surveyCode:(2610 OR 2829 OR 2956)` searches for several study codes
and `*title_es_ES:(+barometro +2024 -sanitario)` combines required and
excluded title terms.

Advanced queries are interpreted by the CIS server. Invalid syntax may
return no results, and relevance ordering can differ from a simple
search. Catalog fields and examples are documented at
<https://www.cis.es/es/estudios/catalogo>.

## Examples

``` r
if (interactive()) {
# Search by search terms
studies <- search_cis(q = "postelectoral")
print(studies)

# Narrow the search by dates
studies <- search_cis(q = "postelectoral",
                          from = "2011-01-01",
                          to = "2020-01-01")
print(studies)

# Use the catalogo parameter to search for questions ("pregunta") or data series ("serie")
studies <- search_cis(q = "ideologia",
                          from = "2011-01-01",
                          to = "2020-01-01",
                          catalogo = "serie")
print(studies)

# Advanced Lucene searches start with an asterisk
studies <- search_cis(q = "*surveyCode:(2610 OR 2829 OR 2956)")
print(studies)

questions <- search_cis(
  q = "*question_es_ES:(divorcio)",
  catalogo = "pregunta"
)
print(questions)
}
```
