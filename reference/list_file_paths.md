# List file paths inside a ZIP archive

Returns a data.frame with the files contained in a ZIP archive,
optionally filtered by file extension.

## Usage

``` r
list_file_paths(zip_file, type = NULL)
```

## Arguments

- zip_file:

  A string with the path to the ZIP file.

- type:

  A string with the file extension to filter by (e.g. `"sav"`, `"pdf"`).
  If `NULL` (default), all files are returned.

## Value

A data.frame with the files in the ZIP archive.
