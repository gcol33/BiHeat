# BiHeat

*two matrices in one heatmap*

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/gcol33/BiHeat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gcol33/BiHeat/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/gcol33/BiHeat/graph/badge.svg)](https://app.codecov.io/gh/gcol33/BiHeat)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Diagonally split heatmap cells: the upper triangle encodes one matrix,
the lower triangle encodes the other.**

`BiHeat` draws two matrices of the same shape in a single heatmap by
cutting every cell along a diagonal. One value goes in the upper
triangle, the other in the lower, built on `ggplot2`. The comparison
lives inside one cell, at the resolution of a single row and column, so
the eye stays in one place.

Neighbours worth knowing:
[corrplot](https://cran.r-project.org/package=corrplot) has
`corrplot.mixed()`, which draws one display above the matrix diagonal
and another below it, for correlation matrices.
[ComplexHeatmap](https://bioconductor.org/packages/ComplexHeatmap/)
reaches a split cell through a custom `cell_fun`, alongside its
clustering and annotation machinery. BiHeat splits each individual cell,
gives each half its own gradient, and takes two plain matrices.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("gcol33/BiHeat")
```

## Quick start

``` r

library(BiHeat)

set.seed(1)
species   <- LETTERS[1:6]
sites     <- letters[1:8]
observed  <- matrix(runif(48), 6, 8, dimnames = list(species, sites))
predicted <- observed + matrix(rnorm(48, sd = 0.1), 6, 8,
                               dimnames = list(species, sites))

biheat(observed, predicted)
```

Upper triangle is `observed` (white to red), lower triangle is
`predicted` (white to blue). Where the two disagree, the split is
visible.

Two matrices of the same shape come up constantly: observed
vs. predicted, mean vs. variance, correlation vs. significance, train
vs. test, model A vs. model B, before vs. after. All of them fit one
BiHeat plot.

## One call or three stages

[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md) is
the one-shot entry point. It is exactly equivalent to the three-stage
lifecycle below, so use whichever reads better in context:

``` r

# one-shot
biheat(observed, predicted, scale = "shared", split = "up")

# lifecycle
breed(observed, predicted) |>
  incubate(scale = "shared", split = "up") |>
  plot()
```

[`breed()`](https://gillescolling.com/BiHeat/reference/breed.md) pairs
the two matrices into a **clutch** and aligns them on overlapping row
and column names, then computes Pearson and Spearman correlation, RMSE,
MAE, and NA counts.
[`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md)
layers on rendering options (additive, the way `ggplot2`’s `+` is).
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) draws.

``` r

clutch <- breed(observed, predicted)
clutch
#> <clutch>
#>   upper: observed (6 x 8)
#>   lower: predicted (6 x 8)
#>   align: intersect  (6 rows x 8 cols kept)
#>   cells: 48 finite / 48 total (0 NA)
#>   pearson: 0.955   rmse: 0.0908   mae: 0.0693
```

## Public API

| Function | Role |
|----|----|
| [`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md) | One-shot heatmap from two matrices |
| [`breed()`](https://gillescolling.com/BiHeat/reference/breed.md) | Pair matrices into a clutch (auto-aligns names) |
| [`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md) | Set rendering options on a clutch (additive) |
| `plot(clutch)` | Render a clutch, panel and paired legend |
| [`switch_sides()`](https://gillescolling.com/BiHeat/reference/switch_sides.md) | Swap which matrix is upper / lower |
| [`straighten()`](https://gillescolling.com/BiHeat/reference/straighten.md) | Flip the diagonal direction |
| [`bothways()`](https://gillescolling.com/BiHeat/reference/bothways.md) | Toggle separate / shared colour scales |
| [`comes_out()`](https://gillescolling.com/BiHeat/reference/comes_out.md) | Pull the tidy data back out |
| [`geom_biheat()`](https://gillescolling.com/BiHeat/reference/geom_biheat.md) | Draw split cells as a ggplot2 layer |
| [`bi_legend()`](https://gillescolling.com/BiHeat/reference/bi_legend.md) | Paired-palette legend as a standalone grob |
| [`palettes()`](https://gillescolling.com/BiHeat/reference/palettes.md) | Bundle paired gradient palettes |
| [`theme_biheat()`](https://gillescolling.com/BiHeat/reference/theme_biheat.md) | Minimal heatmap theme |

The verbs go clutch-in, clutch-out, so they chain:

``` r

breed(observed, predicted) |>
  switch_sides() |>   # swap which matrix is on top
  straighten() |>     # flip the diagonal
  bothways() |>       # toggle separate <-> shared scale
  plot()
```

## Separate or shared scales

- `scale = "separate"` (default) gives the upper and lower triangles
  their own numeric ranges. Use it when the two matrices measure
  different things (correlation vs. p-value, mean vs. variance).
- `scale = "shared"` puts both triangles on a common range, so
  cross-triangle comparisons are meaningful. Use it when the matrices
  are directly comparable (observed vs. predicted in the same units,
  model A vs. model B accuracy).

## Inside a ggplot

[`geom_biheat()`](https://gillescolling.com/BiHeat/reference/geom_biheat.md)
draws the same split cells as a layer, from a long data frame with one
row per cell. Each triangle carries its own gradient, so the `fill`
scale stays free for the rest of the plot.

``` r

library(ggplot2)

cells <- comes_out(breed(observed, predicted))

ggplot(cells, aes(col, row, upper = upper, lower = lower)) +
  geom_biheat() +
  theme_biheat()
```

[`comes_out()`](https://gillescolling.com/BiHeat/reference/comes_out.md)
returns one row per cell, which is the shape the layer wants. Neither
triangle consumes the `fill` scale, so it stays free for another layer,
and facets, coordinate systems, and themes all work as usual.

[`bi_legend()`](https://gillescolling.com/BiHeat/reference/bi_legend.md)
returns the paired-palette key as a standalone grob for figures where
the panel is assembled separately.

## Documentation

- [Getting
  started](https://gillescolling.com/BiHeat/articles/biheat.html)
- [Styling and
  layout](https://gillescolling.com/BiHeat/articles/styling.html)
- [Split cells inside a
  ggplot](https://gillescolling.com/BiHeat/articles/geom-biheat.html)

## License

MIT (c) Gilles Colling. See the LICENSE file.

## Citation

``` bibtex
@software{biheat,
  author = {Colling, Gilles},
  title  = {BiHeat: Diagonally Split Heatmaps for Paired Matrix Visualization},
  year   = {2026},
  url    = {https://github.com/gcol33/BiHeat}
}
```
