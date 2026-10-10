# Breed a pair of matrices into a clutch

Combines two matrices into a `clutch`: aligns them on overlapping row /
column names when both carry dimnames, computes a compact set of
comparison statistics (Pearson and Spearman correlations, RMSE, MAE, NA
counts, value ranges), and stores the aligned matrices alongside a tidy
long form. The result is the canonical BiHeat input — pass it to
[`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md)
to set rendering options and then to
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) to draw, or
straight to [`plot()`](https://rdrr.io/r/graphics/plot.default.html) (or
[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md)) for
defaults.

## Usage

``` r
breed(
  a,
  b,
  upper_name = NULL,
  lower_name = NULL,
  align = c("intersect", "by_position")
)
```

## Arguments

- a, b:

  Matrices (or objects coercible via
  [`as.matrix()`](https://rdrr.io/r/base/matrix.html)). `a` is drawn in
  the upper triangle, `b` in the lower triangle.

- upper_name, lower_name:

  Optional labels. When `NULL`, BiHeat reads the symbol names you passed
  in via [`substitute()`](https://rdrr.io/r/base/substitute.html), so
  `breed(observed, predicted)` records `"observed"` and `"predicted"`
  automatically.

- align:

  `"intersect"` (default) or `"by_position"`.

## Value

A `clutch`: a list with `upper`, `lower`, `data`, `meta`, `align`,
`align_report`, `upper_name`, `lower_name`, `config`.

## Details

Alignment rules (`align = "intersect"`, the default):

- Both matrices carry rownames and colnames: take the intersection on
  each side. The clutch remembers which rows / columns were dropped.

- Only one side carries names on a given axis, or neither does: that
  axis is aligned by position, which requires identical length.

- No overlap on a named axis: error.

Pass `align = "by_position"` to skip the name-based logic entirely and
require identical shape.

## See also

[`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md),
[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md)

## Examples

``` r
set.seed(1)
species <- LETTERS[1:6]
sites   <- letters[1:5]
observed  <- matrix(runif(30), 6, 5, dimnames = list(species, sites))
predicted <- observed + matrix(rnorm(30, sd = 0.1), 6, 5,
                               dimnames = list(species, sites))

clutch <- breed(observed, predicted)
clutch
plot(clutch)
```
