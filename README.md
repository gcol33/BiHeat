# BiHeat

Diagonally split heatmap cells for paired matrix visualization in R.

Each cell shows two values at once: the upper triangle encodes one
matrix, the lower triangle encodes another. One heatmap, two layers, no
overplot.

## Why

Two matrices of the same shape come up everywhere — observed vs.
predicted, mean vs. variance, correlation vs. significance, train vs.
test performance, model A vs. model B, native vs. alien, before vs.
after. The usual workaround is two side-by-side heatmaps and a lot of
eye-tracking between them. BiHeat folds both into one plot.

## Install

```r
# install.packages("remotes")
remotes::install_github("gcol33/BiHeat")
```

## Quick start

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

Upper triangle = `observed` (white -> red). Lower triangle = `predicted`
(white -> blue). Mismatches pop by eye.

## Two ways to call it

`biheat()` is the one-shot entry point. It is exactly equivalent to the
three-stage lifecycle below, so pick whichever reads better in context:

```r
# one-shot
biheat(observed, predicted, scale = "shared", split = "up")

# lifecycle
breed(observed, predicted) |>
  incubate(scale = "shared", split = "up") |>
  plot()
```

`breed()` returns a **clutch** — a paired-matrix object holding the
aligned data plus comparison statistics. `incubate()` configures it.
`plot()` renders it.

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

| Function           | Role                                             |
|--------------------|--------------------------------------------------|
| `biheat()`         | One-shot heatmap from two matrices              |
| `breed()`          | Pair matrices into a clutch (auto-aligns names) |
| `incubate()`       | Set rendering options on a clutch (additive)    |
| `plot(clutch)`     | Render a clutch to a ggplot                     |
| `switch_sides()`   | Swap which matrix is upper / lower              |
| `straighten()`     | Flip the diagonal direction                     |
| `bothways()`       | Toggle separate / shared colour scales          |
| `comes_out()`      | Pull the tidy data back out                     |
| `palettes()`       | Bundle paired gradient palettes                 |
| `theme_biheat()`   | Minimal heatmap theme                           |

`geom_biheat()` and the full split-tile legend are reserved in the API
and land in upcoming milestones.

## Separate vs. shared scales

- `scale = "separate"` (default) — upper and lower each get their own
  numeric range. Right when the two matrices live on different scales
  (correlation vs. p-value, mean vs. variance).
- `scale = "shared"` — both triangles use a common range. Right when
  the two matrices are directly comparable (observed vs. predicted on
  the same units, model A vs. model B accuracy).

## License

MIT (c) Gilles Colling.
