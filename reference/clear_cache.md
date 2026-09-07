# Clear the opencis session cache

Clears the in-memory cache used by
[`search_cis`](https://opencis.spainelectoralproject.com/reference/search_cis.md)
and
[`read_cis`](https://opencis.spainelectoralproject.com/reference/read_cis.md),
the persistent HTTP disk cache, and the HTTP sessions and their cookies.
Call this to force fresh data or a fresh CIS anti-bot verification.

## Usage

``` r
clear_cache(disk = TRUE)
```

## Arguments

- disk:

  Logical. If `TRUE` (the default), also remove all entries from the
  persistent HTTP cache. Set it to `FALSE` to retain downloaded
  responses between sessions.

## Value

`NULL` invisibly.
