# ggplot2 layer for diagonally split heatmap cells

A direct-to-ggplot interface for the drawing
[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md)
performs. Expects a long data frame with one row per cell and `upper` /
`lower` aesthetics holding the two values. Each cell is drawn as two
triangles: `upper` above the diagonal, `lower` below it.

## Usage

``` r
geom_biheat(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  split = c("down", "up"),
  palettes = NULL,
  lower_palette = NULL,
  upper_range = NULL,
  lower_range = NULL,
  cell_inset = 0.04,
  na_colour = "grey90",
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Arguments

- mapping:

  Aesthetic mapping. Required aesthetics are `x`, `y`, `upper`, `lower`;
  `width`, `height`, `colour`, `linewidth`, `linetype` and `alpha` are
  optional.

- data:

  Long data frame, one row per cell.

- stat, position:

  Standard ggplot2 layer arguments.

- ...:

  Other arguments passed on to
  [`ggplot2::layer()`](https://ggplot2.tidyverse.org/reference/layer.html),
  including fixed aesthetics such as `colour` or `linewidth`.

- split:

  `"down"` (top-left to bottom-right diagonal) or `"up"`.

- palettes:

  A
  [`palettes()`](https://gillescolling.com/BiHeat/reference/palettes.md)
  object, or a character vector of upper colours paired with
  `lower_palette`. Defaults to white-to-red over white-to-blue.

- lower_palette:

  Optional companion to a bare `palettes` vector.

- upper_range, lower_range:

  Numeric length-2 value ranges the palettes are stretched across.
  Default to the range of the data in each triangle. Pass the same value
  to both for a shared scale.

- cell_inset:

  Numeric in `[0, 0.5)`. Shrinks each cell on every side to leave a gap
  between neighbours.

- na_colour:

  Fill for `NA` values.

- show.legend, inherit.aes:

  Standard ggplot2 layer arguments.

## Value

A ggplot2 layer.

## Details

The layer carries its own pair of gradient palettes and maps values to
colours itself, so the two triangles keep independent colour ranges
inside a single ggplot. Neither side consumes the `fill` scale, which
leaves it free for other layers. Add a key with
[`bi_legend()`](https://gillescolling.com/BiHeat/reference/bi_legend.md),
or use
[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md) when
you want the legend built for you.

## See also

[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md),
[`bi_legend()`](https://gillescolling.com/BiHeat/reference/bi_legend.md)

## Examples

``` r
set.seed(1)
cells <- expand.grid(site = letters[1:5], species = LETTERS[1:4])
cells$observed  <- runif(20)
cells$predicted <- runif(20)

library(ggplot2)
ggplot(cells, aes(site, species, upper = observed, lower = predicted)) +
  geom_biheat() +
  theme_biheat()
```
