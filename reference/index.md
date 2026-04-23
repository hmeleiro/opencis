# Package index

## Import data

Functions to import CIS study data into R.

- [`read_cis()`](https://opencis.spainelectoralproject.com/reference/read_cis.md)
  : Import a CIS study
- [`download_study()`](https://opencis.spainelectoralproject.com/reference/download_study.md)
  : Download a CIS study ZIP file to disk
- [`get_data_dictionary()`](https://opencis.spainelectoralproject.com/reference/get_data_dictionary.md)
  : Extract a data dictionary from a CIS study data frame

## Search

Functions to search for studies, questions and timeseries in the CIS
catalog.

- [`search_cis()`](https://opencis.spainelectoralproject.com/reference/search_cis.md)
  : Search for CIS studies.
- [`search_all_cis()`](https://opencis.spainelectoralproject.com/reference/search_all_cis.md)
  : Search all CIS results with automatic pagination

## Study details

Functions to retrieve metadata and documents for a specific study.

- [`get_metadata()`](https://opencis.spainelectoralproject.com/reference/get_metadata.md)
  : Get metadata of a CIS study
- [`browse_pdf()`](https://opencis.spainelectoralproject.com/reference/browse_pdf.md)
  : Open the questionnaire PDF of a CIS study

## Utilities

Helper functions for cache management.

- [`clear_cache()`](https://opencis.spainelectoralproject.com/reference/clear_cache.md)
  : Clear the opencis session cache
