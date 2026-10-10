# Build a paired-palette legend (split-tile glyph + gradient bars)

Creates a standalone legend explaining a
[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md) plot:
two horizontal gradient bars (upper and lower triangle palettes) and a
small split-tile glyph whose callouts carry `upper_name` and
`lower_name` alongside the side each one is drawn on. Returns a grob you
can draw with
[`grid::grid.draw()`](https://rdrr.io/r/grid/grid.draw.html) or compose
into another plot.

## Usage

``` r
bi_legend(
  upper_name = "A",
  lower_name = "B",
  upper_palette = c("white", "red"),
  lower_palette = c("white", "blue"),
  upper_range = c(0, 1),
  lower_range = c(0, 1),
  split = c("down", "up")
)
```

## Arguments

- upper_name, lower_name:

  Labels for the two sides.

- upper_palette, lower_palette:

  Colour vectors interpolated across each side.

- upper_range, lower_range:

  Numeric length-2 vectors. Tick labels are drawn at the endpoints and
  midpoint. Default `c(0, 1)`.

- split:

  `"down"` or `"up"` — diagonal direction in the glyph.

## Value

A `bi_legend` object (a grid grob).

## Details

Inside a
[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md) /
[`plot.clutch()`](https://gillescolling.com/BiHeat/reference/plot.clutch.md)
call, the same legend is drawn automatically next to the panel. Use this
function when you want the legend as a standalone graphic (e.g. for a
paper figure where the panel is built separately).

## Examples

``` r
g <- bi_legend("A", "B")
grid::grid.newpage()
grid::grid.draw(g)
```
