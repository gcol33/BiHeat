# Build the split-tile key grob

Returns a grid grob: a small split square with the upper triangle in the
upper palette and the lower triangle in the lower palette, plus two
callout lines running to `upper_name` and `lower_name`, each tagged with
the side it labels.

## Usage

``` r
key_glyph_grob(
  upper_name = "A",
  lower_name = "B",
  upper_palette = c("white", "red"),
  lower_palette = c("white", "blue"),
  split = c("down", "up")
)
```
