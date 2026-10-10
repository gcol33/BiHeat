# Plot a clutch (S3 method for plot())

Renders a
[`breed()`](https://gillescolling.com/BiHeat/reference/breed.md)ed
clutch as a diagonally split heatmap. Reads any configuration set by
[`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md)
and fills in defaults for the rest.

## Usage

``` r
# S3 method for class 'clutch'
plot(x, y, ...)
```

## Arguments

- x:

  A `clutch`.

- y:

  Ignored (required by the
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) S3
  signature).

- ...:

  Additional rendering options. Treated as a final
  [`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md)
  pass before drawing.

## Value

A `biheat_plot` gtable, or the underlying ggplot when no key glyph is
drawn (`legend_position = "none"` or `show_key = FALSE`).
