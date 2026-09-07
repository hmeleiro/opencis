# Changelog

## opencis 0.1.2

### New features

- Added automatic handling of the CIS proof-of-work anti-bot challenge.
  HTTP requests now keep a stable session and user agent, preserve
  cookies, extract the challenge parameters from the returned HTML,
  solve the SHA-256 proof of work, submit it to the CIS endpoint, and
  retry the original request.

- Added a persistent HTTP disk cache for successful CIS responses,
  including catalog pages, study pages, and ZIP downloads. Cached
  entries expire after 24 hours by default and are evicted using an LRU
  policy when the cache reaches its default 512 MB limit.

- Added
  [`cache_info()`](https://opencis.spainelectoralproject.com/reference/cache_info.md)
  to inspect the active cache directory, expiration and size limits,
  entry count, and current disk usage.

### Improvements

- [`clear_cache()`](https://opencis.spainelectoralproject.com/reference/clear_cache.md)
  now clears memoised results, persistent HTTP responses, HTTP sessions,
  and session cookies. Use `clear_cache(disk = FALSE)` to retain the
  persistent disk cache.

- Anti-bot challenge pages, unsuccessful HTTP responses, and
  `Set-Cookie` headers are excluded from the disk cache.

- Added configuration options for enabling the cache, choosing its
  directory, and controlling expiration and maximum size:
  `opencis.cache`, `opencis.cache_dir`, `opencis.cache_max_age`, and
  `opencis.cache_max_size`.

- Added automated tests covering proof-of-work calculation, challenge
  parsing, session reuse, persistent response caching, binary downloads,
  cache clearing, and exclusion of sensitive or unsuccessful responses.

- Network-dependent examples now run only in interactive sessions so
  package checks do not depend on the availability of the external CIS
  service.
