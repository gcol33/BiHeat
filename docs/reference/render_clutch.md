# Render a configured clutch into a plot

Internal renderer. Reads `x$config`, fills any unset slot from
[`clutch_defaults()`](https://gillescolling.com/BiHeat/reference/clutch_defaults.md),
validates enum values, and builds a ggplot with two fill scales (one per
triangle) via
[`ggnewscale::new_scale_fill()`](https://eliocamp.github.io/ggnewscale/reference/new_scale.html).
Returns a `biheat_plot` object: a gtable that wraps the ggplot grob plus
the optional split-tile key glyph injected into the legend column.

## Usage

``` r
render_clutch(x)
```
