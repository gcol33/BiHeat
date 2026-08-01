# BiHeat 0.1.0

First release.

* `biheat()` draws two matrices of the same shape in one heatmap, splitting
  every cell along a diagonal.
* `breed()`, `incubate()` and `plot()` expose the same drawing as a
  three-stage lifecycle around a `clutch` object, which carries the aligned
  matrices, a tidy long form, and comparison statistics.
* `switch_sides()`, `straighten()`, `bothways()` and `comes_out()` operate
  clutch-in, clutch-out.
* `geom_biheat()` draws split cells as a ggplot2 layer. Each triangle carries
  its own gradient, leaving the `fill` scale free for other layers.
* `bi_legend()` returns the paired-palette key as a standalone grob.
* `palettes()` bundles a pair of gradient palettes; `theme_biheat()` supplies
  a minimal heatmap theme.
* Three vignettes: `vignette("biheat")` for the clutch, alignment, and the
  lifecycle, `vignette("styling")` for the rendering options, and
  `vignette("geom-biheat")` for the ggplot2 layer.
