# A minimal heatmap theme for BiHeat plots

Drops panel grids and backgrounds, lays x labels horizontally on the
bottom, centres the title block, italicises the caption, and tightens
margins. Built on top of
[`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
— pass a different base via `base` to start from another theme.

## Usage

``` r
theme_biheat(
  base_size = 11,
  base = ggplot2::theme_minimal(base_size = base_size)
)
```

## Arguments

- base_size:

  Base font size.

- base:

  A ggplot2 theme to inherit from. Defaults to
  [`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).

## Value

A ggplot2 `theme` object.
