# Changelog

## BiHeat 0.1.0

First release.

- [`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md)
  draws two matrices of the same shape in one heatmap, splitting every
  cell along a diagonal.
- [`breed()`](https://gillescolling.com/BiHeat/reference/breed.md),
  [`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md)
  and [`plot()`](https://rdrr.io/r/graphics/plot.default.html) expose
  the same drawing as a three-stage lifecycle around a `clutch` object,
  which carries the aligned matrices, a tidy long form, and comparison
  statistics.
- [`switch_sides()`](https://gillescolling.com/BiHeat/reference/switch_sides.md),
  [`straighten()`](https://gillescolling.com/BiHeat/reference/straighten.md),
  [`bothways()`](https://gillescolling.com/BiHeat/reference/bothways.md)
  and
  [`comes_out()`](https://gillescolling.com/BiHeat/reference/comes_out.md)
  operate clutch-in, clutch-out.
- [`geom_biheat()`](https://gillescolling.com/BiHeat/reference/geom_biheat.md)
  draws split cells as a ggplot2 layer. Each triangle carries its own
  gradient, leaving the `fill` scale free for other layers.
- [`bi_legend()`](https://gillescolling.com/BiHeat/reference/bi_legend.md)
  returns the paired-palette key as a standalone grob.
- [`palettes()`](https://gillescolling.com/BiHeat/reference/palettes.md)
  bundles a pair of gradient palettes;
  [`theme_biheat()`](https://gillescolling.com/BiHeat/reference/theme_biheat.md)
  supplies a minimal heatmap theme.
- Three vignettes:
  [`vignette("biheat")`](https://gillescolling.com/BiHeat/articles/biheat.md)
  for the clutch, alignment, and the lifecycle,
  [`vignette("styling")`](https://gillescolling.com/BiHeat/articles/styling.md)
  for the rendering options, and
  [`vignette("geom-biheat")`](https://gillescolling.com/BiHeat/articles/geom-biheat.md)
  for the ggplot2 layer.
