# Map numeric values to colours using a gradient palette

Internal helper. Rescales values to `[0, 1]` against a numeric range and
applies a gradient palette function. Out-of-range values are clamped.
`NA` values receive `na_colour`. A degenerate range (`min == max`) maps
every non-`NA` value to the palette midpoint.

## Usage

``` r
map_colour(x, rng, pal_fn, na_colour)
```
