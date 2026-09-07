# Inspect the opencis HTTP cache

Reports the active disk-cache configuration and current usage. The cache
is enabled by default and stores successful CIS responses for 24 hours.

## Usage

``` r
cache_info()
```

## Value

A named list containing the cache state, directory, limits, number of
entries, and current size in bytes.

## Details

Configure it with the options `opencis.cache`, `opencis.cache_dir`,
`opencis.cache_max_age` (seconds), and `opencis.cache_max_size` (bytes).
