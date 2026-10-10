# Paired gradient palettes for BiHeat

Bundles two gradient palettes — one for the upper triangle, one for the
lower triangle — into a single object you can pass to
[`biheat()`](https://gillescolling.com/BiHeat/reference/biheat.md) or
[`incubate()`](https://gillescolling.com/BiHeat/reference/incubate.md).
Each side is a character vector of two or more colours, which
[`scales::gradient_n_pal()`](https://scales.r-lib.org/reference/pal_gradient_n.html)
interpolates across `[0, 1]`.

## Usage

``` r
palettes(upper = c("white", "red"), lower = c("white", "blue"))
```

## Arguments

- upper:

  Character vector of colours for the upper-triangle palette.

- lower:

  Character vector of colours for the lower-triangle palette.

## Value

An object of class `palettes`: a list with elements `upper` and `lower`.

## Examples

``` r
palettes(upper = c("white", "darkred"),
         lower = c("white", "navy"))
```
