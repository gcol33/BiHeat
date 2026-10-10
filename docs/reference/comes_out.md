# Extract the tidy data from a clutch or rendered plot

Pulls out the per-cell long table — useful for piping into another
visualisation or for inspection.

## Usage

``` r
comes_out(x)
```

## Arguments

- x:

  A `clutch`, or a ggplot returned by
  [`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md) /
  [`plot.clutch()`](https://gillescolling.com/BiHeat/reference/plot.clutch.md).

## Value

A data frame with columns `row`, `col`, `i`, `j`, `upper`, `lower`.
