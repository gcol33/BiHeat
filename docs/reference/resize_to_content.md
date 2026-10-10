# Refit a gtable's viewport around its rows

The guide box arrives in a viewport measured for the guides it held at
build time. Rows added afterwards fall outside that measurement, and
grid centres the overflow, cutting the top guide off. Re-anchoring the
viewport on the current row heights lets the box grow downward instead.

## Usage

``` r
resize_to_content(gt)
```
