# Tidy two matrices into one row per cell

Internal helper used by
[`breed()`](https://gillescolling.com/BiHeat/reference/breed.md).
Validates inputs, then returns a long data frame with columns `row`,
`col`, `i`, `j`, `upper`, `lower`. Row / column orders are preserved on
attributes.

## Usage

``` r
as_biheat_data(upper, lower, upper_name = "upper", lower_name = "lower")
```
