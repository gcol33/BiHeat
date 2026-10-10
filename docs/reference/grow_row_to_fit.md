# Grow the layout row holding a guide box to the box's new height

A guide box below the panel occupies a row sized for the guides it held
when the plot was built. The key glyph adds rows after that measurement,
and the surplus is drawn outside the row and clipped. Widening the row
to the box's current height lets the glyph land inside the figure. A
guide box beside the panel grows along the axis its row does not
constrain, so it is left alone.

## Usage

``` r
grow_row_to_fit(g, idx, guide_box)
```
