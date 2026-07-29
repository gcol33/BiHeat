#' Configure a clutch for rendering
#'
#' Sets rendering options on a [breed()]ed clutch. Returns the clutch with
#' those options stored on it; calls are *additive*, so options layer the
#' way ggplot2's `+` does:
#'
#' ```
#' breed(a, b) |>
#'   incubate(scale = "shared") |>
#'   incubate(split = "up")
#' ```
#'
#' produces a clutch with both `scale = "shared"` and `split = "up"`.
#' Pass `NULL` to leave an option at its rendering default; the function
#' only records arguments you explicitly set.
#'
#' All arguments other than `x` are optional. Values are validated at
#' render time so that incremental [incubate()] calls don't reject
#' otherwise-fine partial configurations.
#'
#' @param x A `clutch` from [breed()].
#' @param palettes A [palettes()] object, or a character vector of upper
#'   colours (paired with `lower_palette`).
#' @param lower_palette Optional companion to a bare `palettes` vector.
#' @param scale `"separate"` or `"shared"`. Whether upper / lower triangles
#'   share a single value range.
#' @param split `"down"` or `"up"`. Diagonal direction.
#' @param legend_position `"right"`, `"bottom"`, or `"none"`.
#' @param legend_orientation `"vertical"` or `"horizontal"`.
#' @param show_values Logical. Print each value inside its triangle.
#' @param value_size Numeric text size for value labels.
#' @param grid_colour Colour of the grid between triangles / cells.
#' @param grid_linewidth Width of grid lines.
#' @param cell_inset Numeric in `[0, 0.5)`. Shrinks each cell on every side
#'   to leave a thin gap between neighbouring cells. Default `0.04`. Pass
#'   `0` for contiguous cells.
#' @param na_colour Fill for `NA` cells.
#' @param row_order,col_order Optional character vectors giving manual row /
#'   column orders. Must be permutations of the clutch's row / column
#'   labels.
#' @param xlab,ylab,title Axis and plot titles.
#' @param subtitle,caption Optional plot subtitle and caption strings.
#' @param show_key Logical. If `TRUE` (default), inject a split-tile key
#'   glyph below the legend colourbars explaining which triangle is which.
#' @param upper_name,lower_name Override the labels stored on the clutch.
#'
#' @return The clutch, with the supplied options merged into its `config`.
#'
#' @examples
#' set.seed(1)
#' u <- matrix(runif(20), 4, 5)
#' l <- matrix(runif(20), 4, 5)
#' breed(u, l) |>
#'   incubate(scale = "shared", split = "up") |>
#'   plot()
#'
#' @seealso [breed()], [plot.clutch()]
#' @export
incubate <- function(x,
                     palettes           = NULL,
                     lower_palette      = NULL,
                     scale              = NULL,
                     split              = NULL,
                     legend_position    = NULL,
                     legend_orientation = NULL,
                     show_values        = NULL,
                     value_size         = NULL,
                     grid_colour        = NULL,
                     grid_linewidth     = NULL,
                     cell_inset         = NULL,
                     na_colour          = NULL,
                     row_order          = NULL,
                     col_order          = NULL,
                     xlab               = NULL,
                     ylab               = NULL,
                     title              = NULL,
                     subtitle           = NULL,
                     caption            = NULL,
                     show_key           = NULL,
                     upper_name         = NULL,
                     lower_name         = NULL) {

  if (!inherits(x, "clutch")) {
    stop_biheat("`incubate()` expects a clutch (from `breed()`).")
  }

  if (!is.null(palettes) || !is.null(lower_palette)) {
    palettes <- as_palettes(palettes, lower_palette)
  }

  new_config <- list(
    palettes           = palettes,
    scale              = scale,
    split              = split,
    legend_position    = legend_position,
    legend_orientation = legend_orientation,
    show_values        = show_values,
    value_size         = value_size,
    grid_colour        = grid_colour,
    grid_linewidth     = grid_linewidth,
    cell_inset         = cell_inset,
    na_colour          = na_colour,
    row_order          = row_order,
    col_order          = col_order,
    xlab               = xlab,
    ylab               = ylab,
    title              = title,
    subtitle           = subtitle,
    caption            = caption,
    show_key           = show_key
  )
  new_config <- new_config[!vapply(new_config, is.null, logical(1L))]

  if (!is.null(upper_name)) x$upper_name <- upper_name
  if (!is.null(lower_name)) x$lower_name <- lower_name

  x$config <- utils::modifyList(x$config %||% list(), new_config)
  x
}

#' Default rendering config for a clutch
#' @keywords internal
clutch_defaults <- function() {
  list(
    palettes           = palettes(c("white", "red"), c("white", "blue")),
    scale              = "separate",
    split              = "down",
    legend_position    = "right",
    legend_orientation = "vertical",
    show_values        = FALSE,
    value_size         = 3,
    grid_colour        = NA,
    grid_linewidth     = 0,
    cell_inset         = 0.04,
    na_colour          = "grey90",
    row_order          = NULL,
    col_order          = NULL,
    xlab               = NULL,
    ylab               = NULL,
    title              = NULL,
    subtitle           = NULL,
    caption            = NULL,
    show_key           = TRUE
  )
}
