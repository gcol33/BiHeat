# Expand cell-level data into triangle polygon coordinates

Internal helper shared by the clutch renderer and
[`geom_biheat()`](https://gillescolling.com/BiHeat/reference/geom_biheat.md).
Given a data frame of cell centres, returns a long data frame of polygon
vertices suitable for
[`grid::polygonGrob()`](https://rdrr.io/r/grid/grid.polygon.html) or
[`ggplot2::geom_polygon()`](https://ggplot2.tidyverse.org/reference/geom_polygon.html).
Two polygons are produced per input row: one for the upper-value
triangle and one for the lower-value triangle.

## Usage

``` r
build_triangles(data, split = c("down", "up"), inset = 0)
```

## Arguments

- data:

  A data frame with numeric `x`, `y` (cell centres) and `upper`, `lower`
  (cell values). Optional numeric `width` and `height` columns give
  per-cell footprints; both default to `1`.

- split:

  One of `"down"` (top-left to bottom-right diagonal) or `"up"`
  (bottom-left to top-right diagonal).

- inset:

  Numeric in `[0, 0.5)`. Shrinks each cell's footprint by this fraction
  of its width and height on every side, opening a gap between
  neighbouring cells. `0` gives contiguous cells; `0.04` gives an ~8%
  gap.

## Value

A data frame with columns `x`, `y`, `polygon_id`, `which`, `value`,
`.row` (the index of the source row in `data`).

## Details

Coordinates follow the display convention, so `y` grows upward: for
`split = "down"` the cell is cut from its top-left to its bottom-right
corner and the upper triangle is the one above that cut.
