# Diagonally split heatmap of two matrices

Draws a heatmap where each cell is split along a diagonal: the upper
triangle shows the corresponding value of `upper`, the lower triangle
the value of `lower`. Use for compact paired comparisons — observed vs.
predicted, mean vs. variance, correlation vs. significance, train vs.
test performance.

## Usage

``` r
biheat(upper, lower, ...)
```

## Arguments

- upper:

  Numeric matrix, drawn in the upper triangle. If you pass a `clutch`
  here, `lower` must be omitted.

- lower:

  Numeric matrix, drawn in the lower triangle.

- ...:

  Rendering options passed straight to
  [`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md):
  `palettes`, `scale`, `split`, `legend_position`, `legend_orientation`,
  `show_values`, `value_size`, `grid_colour`, `grid_linewidth`,
  `na_colour`, `row_order`, `col_order`, `xlab`, `ylab`, `title`,
  `upper_name`, `lower_name`.

## Value

A `biheat_plot`: a gtable carrying the panel and the paired legend,
which prints like any other plot. With `legend_position = "none"` or
`show_key = FALSE` there is no key glyph to inject, and the return is
the underlying ggplot object.

## Details

`biheat()` is the one-shot entry point. It is sugar over the lifecycle
[`breed()`](https://gillescolling.com/BiHeat/reference/breed.md) -\>
[`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md)
-\> [`plot()`](https://rdrr.io/r/graphics/plot.default.html), so:

    biheat(observed, predicted, scale = "shared")

is exactly:

    breed(observed, predicted) |>
      incubate(scale = "shared") |>
      plot()

Use the lifecycle directly when you want to inspect or compose with the
paired object —
[`breed()`](https://gillescolling.com/BiHeat/reference/breed.md) returns
a `clutch` carrying the aligned matrices, a tidy long form, and
comparison statistics (correlation, RMSE, MAE).

## See also

[`breed()`](https://gillescolling.com/BiHeat/reference/breed.md),
[`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md),
[`plot.clutch()`](https://gillescolling.com/BiHeat/reference/plot.clutch.md)

## Examples

``` r
set.seed(1)
u <- matrix(runif(20), 4, 5, dimnames = list(LETTERS[1:4], letters[1:5]))
l <- matrix(rnorm(20), 4, 5, dimnames = list(LETTERS[1:4], letters[1:5]))

biheat(u, l)
biheat(u, l, scale = "shared", split = "up")

# equivalent lifecycle form
breed(u, l) |> incubate(scale = "shared") |> plot()
```
