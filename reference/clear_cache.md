# Clear the opencis session cache

Clears the in-memory cache used by
[`search_cis`](https://opencis.spainelectoralproject.com/reference/search_cis.md)
and
[`read_cis`](https://opencis.spainelectoralproject.com/reference/read_cis.md).
Call this when you want to force fresh data to be retrieved from the CIS
server within the same R session.

## Usage

``` r
clear_cache()
```

## Value

`NULL` invisibly.
