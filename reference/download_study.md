# Download a CIS study ZIP file to disk

Downloads the data ZIP file for a CIS study to a specified directory,
instead of a temporary folder. Useful for projects that need to keep the
raw data files.

## Usage

``` r
download_study(study_code, destdir = ".")
```

## Arguments

- study_code:

  A string with the study code.

- destdir:

  A string with the directory where the ZIP file will be saved. Defaults
  to the current working directory.

## Value

The path to the saved ZIP file, invisibly.

## Examples

``` r
# \donttest{
# Save the ZIP file to a temporary directory
path <- download_study("3328", destdir = tempdir())
cat("Saved to:", path, "\n")
#> Saved to: /tmp/RtmpDcG2lX/MD3328.zip 
# }
```
