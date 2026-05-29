# BiHeat

*you keep flicking back to the other heatmap*

[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Diagonally split heatmap cells: the upper triangle encodes one matrix, the lower triangle encodes the other.**

`BiHeat` draws two matrices of the same shape in a single heatmap by cutting every
cell along a diagonal. One value goes in the upper triangle, the other in the lower,
built on `ggplot2`. The usual approach puts two heatmaps side by side and leaves you
tracking your eye between them; here the comparison lives inside one cell.

```r
library(BiHeat)

set.seed(1)
species   <- LETTERS[1:6]
sites     <- letters[1:8]
observed  <- matrix(runif(48), 6, 8, dimnames = list(species, sites))
predicted <- observed + matrix(rnorm(48, sd = 0.1), 6, 8,
                               dimnames = list(species, sites))

biheat(observed, predicted)
```

Upper triangle is `observed` (white to red), lower triangle is `predicted`
(white to blue). Where the two disagree, the split is visible.

Two matrices of the same shape come up constantly: observed vs. predicted, mean vs.
variance, correlation vs. significance, train vs. test, model A vs. model B,
before vs. after. All of them fit one BiHeat plot.

## One call or three stages

`biheat()` is the one-shot entry point. It is exactly equivalent to the three-stage
lifecycle below, so use whichever reads better in context:

```r
# one-shot
biheat(observed, predicted, scale = "shared", split = "up")

# lifecycle
breed(observed, predicted) |>
  incubate(scale = "shared", split = "up") |>
  plot()
```

`breed()` pairs the two matrices into a **clutch** and aligns them on overlapping
row and column names, then computes Pearson and Spearman correlation, RMSE, MAE, and
NA counts. `incubate()` layers on rendering options (additive, the way `ggplot2`'s
`+` is). `plot()` draws.

```r
clutch <- breed(observed, predicted)
clutch
#> <clutch>
#>   upper: observed  (6 x 8)
#>   lower: predicted (6 x 8)
#>   align: intersect  (6 rows x 8 cols kept)
#>   cells: 48 finite / 48 total (0 NA)
#>   pearson: 0.95   rmse: 0.10   mae: 0.08
```

## Public API

| Function         | Role                                            |
|------------------|-------------------------------------------------|
| `biheat()`       | One-shot heatmap from two matrices              |
| `breed()`        | Pair matrices into a clutch (auto-aligns names) |
| `incubate()`     | Set rendering options on a clutch (additive)    |
| `plot(clutch)`   | Render a clutch to a ggplot                      |
| `switch_sides()` | Swap which matrix is upper / lower              |
| `straighten()`   | Flip the diagonal direction                     |
| `bothways()`     | Toggle separate / shared colour scales          |
| `comes_out()`    | Pull the tidy data back out                     |
| `palettes()`     | Bundle paired gradient palettes                 |
| `theme_biheat()` | Minimal heatmap theme                           |

The verbs go clutch-in, clutch-out, so they chain:

```r
breed(observed, predicted) |>
  switch_sides() |>   # swap which matrix is on top
  straighten() |>     # flip the diagonal
  bothways() |>       # toggle separate <-> shared scale
  plot()
```

## Separate or shared scales

- `scale = "separate"` (default) gives the upper and lower triangles their own
  numeric ranges. Use it when the two matrices measure different things
  (correlation vs. p-value, mean vs. variance).
- `scale = "shared"` puts both triangles on a common range, so cross-triangle
  comparisons are meaningful. Use it when the matrices are directly comparable
  (observed vs. predicted in the same units, model A vs. model B accuracy).

## Installation

```r
# install.packages("remotes")
remotes::install_github("gcol33/BiHeat")
```

## Documentation

- [Getting started](https://github.com/gcol33/BiHeat/blob/main/vignettes/biheat.Rmd)

`geom_biheat()` and the full split-tile legend are reserved in the API and land in
a later milestone.

## License

MIT (c) Gilles Colling. See the LICENSE file.
