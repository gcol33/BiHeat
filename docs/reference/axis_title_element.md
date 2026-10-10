# Axis title element for an optional label

[`theme_biheat()`](https://gillescolling.com/BiHeat/reference/theme_biheat.md)
blanks both axis titles, since a heatmap's tick labels usually name the
axis on their own. A label supplied through
[`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md)
has to switch its own title back on.

## Usage

``` r
axis_title_element(label, axis = c("x", "y"))
```
