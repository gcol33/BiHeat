# Swap which matrix is on top

Exchanges the upper and lower triangles of a clutch.

## Usage

``` r
switch_sides(x)
```

## Arguments

- x:

  A `clutch` from
  [`breed()`](https://gillescolling.com/BiHeat/reference/breed.md).

## Value

A `clutch` with `upper` / `lower` exchanged and their `*_name` slots
swapped.

## Examples

``` r
u <- matrix(1:6, 2, 3); l <- matrix(7:12, 2, 3)
breed(u, l, "obs", "pred") |> switch_sides()
```
