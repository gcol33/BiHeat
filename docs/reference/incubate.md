# Configure a clutch for rendering

Sets rendering options on a
[`breed()`](https://gillescolling.com/BiHeat/reference/breed.md)ed
clutch. Returns the clutch with those options stored on it; calls are
*additive*, so options layer the way ggplot2's `+` does:

## Usage

``` r
incubate(
  x,
  palettes = NULL,
  lower_palette = NULL,
  scale = NULL,
  split = NULL,
  legend_position = NULL,
  legend_orientation = NULL,
  show_values = NULL,
  value_size = NULL,
  grid_colour = NULL,
  grid_linewidth = NULL,
  cell_inset = NULL,
  na_colour = NULL,
  row_order = NULL,
  col_order = NULL,
  xlab = NULL,
  ylab = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  show_key = NULL,
  upper_name = NULL,
  lower_name = NULL
)
```

## Arguments

- x:

  A `clutch` from
  [`breed()`](https://gillescolling.com/BiHeat/reference/breed.md).

- palettes:

  A
  [`palettes()`](https://gillescolling.com/BiHeat/reference/palettes.md)
  object, or a character vector of upper colours (paired with
  `lower_palette`).

- lower_palette:

  Optional companion to a bare `palettes` vector.

- scale:

  `"separate"` or `"shared"`. Whether upper / lower triangles share a
  single value range.

- split:

  `"down"` or `"up"`. Diagonal direction.

- legend_position:

  `"right"`, `"bottom"`, or `"none"`.

- legend_orientation:

  `"vertical"` or `"horizontal"`.

- show_values:

  Logical. Print each value inside its triangle.

- value_size:

  Numeric text size for value labels.

- grid_colour:

  Colour of the grid between triangles / cells.

- grid_linewidth:

  Width of grid lines.

- cell_inset:

  Numeric in `[0, 0.5)`. Shrinks each cell on every side to leave a thin
  gap between neighbouring cells. Default `0.04`. Pass `0` for
  contiguous cells.

- na_colour:

  Fill for `NA` cells.

- row_order, col_order:

  Optional character vectors giving manual row / column orders. Must be
  permutations of the clutch's row / column labels.

- xlab, ylab, title:

  Axis and plot titles.

- subtitle, caption:

  Optional plot subtitle and caption strings.

- show_key:

  Logical. If `TRUE` (default), inject a split-tile key glyph below the
  legend colourbars explaining which triangle is which.

- upper_name, lower_name:

  Override the labels stored on the clutch.

## Value

The clutch, with the supplied options merged into its `config`.

## Details

    breed(a, b) |>
      incubate(scale = "shared") |>
      incubate(split = "up")

produces a clutch with both `scale = "shared"` and `split = "up"`. Pass
`NULL` to leave an option at its rendering default; the function only
records arguments you explicitly set.

All arguments other than `x` are optional. Values are validated at
render time so that incremental `incubate()` calls don't reject
otherwise-fine partial configurations.

## See also

[`breed()`](https://gillescolling.com/BiHeat/reference/breed.md),
[`plot.clutch()`](https://gillescolling.com/BiHeat/reference/plot.clutch.md)

## Examples

``` r
set.seed(1)
u <- matrix(runif(20), 4, 5)
l <- matrix(runif(20), 4, 5)
breed(u, l) |>
  incubate(scale = "shared", split = "up") |>
  plot()
```
