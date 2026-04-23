# Open the questionnaire PDF of a CIS study

Opens a PDF document from a CIS study in the default browser.

## Usage

``` r
browse_pdf(study_code, wanted_file = "cues")
```

## Arguments

- study_code:

  A string with the study code.

- wanted_file:

  A keyword used to match the PDF filename inside the ZIP. Use `"cues"`
  (default) for the questionnaire or `"ft"` for the technical sheet.

## Value

Called for its side effect of opening the PDF in the browser. Returns
`NULL` invisibly.

## Details

CIS study ZIP files typically contain two PDF documents:

- The **questionnaire** (cuestionario): use `wanted_file = "cues"`.

- The **technical sheet** (ficha técnica): use `wanted_file = "ft"`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Open the questionnaire (cuestionario) for study 3328
browse_pdf("3328")

# Open the technical sheet (ficha técnica) for study 3328
browse_pdf("3328", wanted_file = "ft")
} # }
```
