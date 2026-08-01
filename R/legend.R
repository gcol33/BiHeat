#' Build a paired-palette legend (split-tile glyph + gradient bars)
#'
#' Creates a standalone legend explaining a [biheat()] plot: two horizontal
#' gradient bars (upper and lower triangle palettes) and a small split-tile
#' glyph whose callouts carry `upper_name` and `lower_name` alongside the
#' side each one is drawn on. Returns a grob you can draw with
#' [grid::grid.draw()] or compose into another plot.
#'
#' Inside a [biheat()] / [plot.clutch()] call, the same legend is drawn
#' automatically next to the panel. Use this function when you want the
#' legend as a standalone graphic (e.g. for a paper figure where the panel
#' is built separately).
#'
#' @param upper_name,lower_name Labels for the two sides.
#' @param upper_palette,lower_palette Colour vectors interpolated across
#'   each side.
#' @param upper_range,lower_range Numeric length-2 vectors. Tick labels are
#'   drawn at the endpoints and midpoint. Default `c(0, 1)`.
#' @param split `"down"` or `"up"` — diagonal direction in the glyph.
#'
#' @return A `bi_legend` object (a grid grob).
#'
#' @examples
#' g <- bi_legend("A", "B")
#' grid::grid.newpage()
#' grid::grid.draw(g)
#'
#' @export
bi_legend <- function(upper_name    = "A",
                      lower_name    = "B",
                      upper_palette = c("white", "red"),
                      lower_palette = c("white", "blue"),
                      upper_range   = c(0, 1),
                      lower_range   = c(0, 1),
                      split         = c("down", "up")) {
  split <- match.arg(split)

  check_range(upper_range, "upper_range")
  check_range(lower_range, "lower_range")

  bar_upper <- bar_grob(upper_name, upper_palette, upper_range, y_top = 0.95)
  bar_lower <- bar_grob(lower_name, lower_palette, lower_range, y_top = 0.65)
  key <- key_glyph_grob(
    upper_name    = upper_name,
    lower_name    = lower_name,
    upper_palette = upper_palette,
    lower_palette = lower_palette,
    split         = split
  )
  key_vp <- grid::viewport(
    x = 0.5, y = 0.15,
    width  = grid::unit(1, "npc"),
    height = grid::unit(0.25, "npc"),
    just = c("center", "center")
  )

  out <- grid::gTree(
    children = grid::gList(
      bar_upper,
      bar_lower,
      grid::editGrob(key, vp = key_vp)
    ),
    name = "bi_legend"
  )

  class(out) <- c("bi_legend", class(out))
  attr(out, "spec") <- list(
    upper_name = upper_name, lower_name = lower_name,
    upper_palette = upper_palette, lower_palette = lower_palette,
    upper_range = upper_range, lower_range = lower_range,
    split = split
  )
  out
}

#' One horizontal gradient bar with a title and 3 tick labels
#' @keywords internal
bar_grob <- function(title, palette, range, y_top = 0.95,
                     bar_height = 0.05, bar_width = 0.7) {
  x0 <- 0.05; x1 <- x0 + bar_width
  ramp <- scales::gradient_n_pal(palette)(seq(0, 1, length.out = 256))
  bar <- grid::rasterGrob(
    image = matrix(ramp, nrow = 1),
    x = x0, y = y_top - bar_height - 0.04,
    width  = bar_width,
    height = bar_height,
    just   = c("left", "bottom"),
    interpolate = TRUE
  )
  title_grob <- grid::textGrob(
    title, x = x0, y = y_top, hjust = 0,
    gp = grid::gpar(fontface = "bold", fontsize = 10)
  )
  ticks_x <- c(x0, x0 + bar_width / 2, x1)
  ticks_y <- y_top - bar_height - 0.04
  ticks_g <- grid::segmentsGrob(
    x0 = ticks_x, x1 = ticks_x,
    y0 = ticks_y, y1 = ticks_y - 0.01,
    gp = grid::gpar(col = "grey25", lwd = 0.6)
  )
  mid <- mean(range)
  # Round first, then format each tick on its own. Formatting the three
  # together stretches every label to the decimals the smallest one needs,
  # and a common width would push the centred labels off their ticks.
  labels <- vapply(
    signif(c(range[1], mid, range[2]), 3),
    function(v) format(v, trim = TRUE),
    character(1L)
  )
  label_g <- grid::textGrob(
    labels,
    x = ticks_x, y = ticks_y - 0.03, hjust = 0.5, vjust = 1,
    gp = grid::gpar(fontsize = 8, col = "grey20")
  )
  grid::gTree(children = grid::gList(title_grob, bar, ticks_g, label_g))
}

#' @export
#' @keywords internal
print.bi_legend <- function(x, ...) {
  grid::grid.newpage()
  grid::grid.draw(x)
  invisible(x)
}
