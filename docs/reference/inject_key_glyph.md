# Inject a split-tile key glyph below the legend colourbars

Converts a ggplot to a gtable, builds a
[`key_glyph_grob()`](https://gillescolling.com/BiHeat/reference/key_glyph_grob.md)
explaining which triangle is which, and inserts it into the guide-box
gtable. Returns a `biheat_plot` (gtable subclass).

## Usage

``` r
inject_key_glyph(p, spec)
```
