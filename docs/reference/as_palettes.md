# Resolve user palette input into a `palettes` object

Accepts what the user-facing entry points accept: a `palettes` object, a
bare vector of upper colours optionally paired with `lower_palette`, or
`NULL` for the defaults.

## Usage

``` r
as_palettes(x, lower_palette = NULL)
```
