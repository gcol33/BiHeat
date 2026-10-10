# Package index

## Draw

Two matrices in, one diagonally split heatmap out.

- [`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md) :
  Diagonally split heatmap of two matrices
- [`geom_biheat()`](https://gillescolling.com/BiHeat/reference/geom_biheat.md)
  : ggplot2 layer for diagonally split heatmap cells

## The lifecycle

Pair the matrices, configure the rendering, draw.

- [`breed()`](https://gillescolling.com/BiHeat/reference/breed.md) :
  Breed a pair of matrices into a clutch
- [`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md)
  : Configure a clutch for rendering
- [`plot(`*`<clutch>`*`)`](https://gillescolling.com/BiHeat/reference/plot.clutch.md)
  : Plot a clutch (S3 method for plot())

## Verbs

Clutch in, clutch out, so they chain.

- [`switch_sides()`](https://gillescolling.com/BiHeat/reference/switch_sides.md)
  : Swap which matrix is on top
- [`straighten()`](https://gillescolling.com/BiHeat/reference/straighten.md)
  : Flip the diagonal direction
- [`bothways()`](https://gillescolling.com/BiHeat/reference/bothways.md)
  : Toggle between shared and separate colour scales
- [`comes_out()`](https://gillescolling.com/BiHeat/reference/comes_out.md)
  : Extract the tidy data from a clutch or rendered plot

## Appearance

Palettes, the heatmap theme, and the paired legend as a standalone grob.

- [`palettes()`](https://gillescolling.com/BiHeat/reference/palettes.md)
  : Paired gradient palettes for BiHeat
- [`theme_biheat()`](https://gillescolling.com/BiHeat/reference/theme_biheat.md)
  : A minimal heatmap theme for BiHeat plots
- [`bi_legend()`](https://gillescolling.com/BiHeat/reference/bi_legend.md)
  : Build a paired-palette legend (split-tile glyph + gradient bars)

## Package

- [`BiHeat`](https://gillescolling.com/BiHeat/reference/BiHeat-package.md)
  [`BiHeat-package`](https://gillescolling.com/BiHeat/reference/BiHeat-package.md)
  : BiHeat: Diagonally Split Heatmaps for Paired Matrix Visualization
