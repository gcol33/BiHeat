#' Diagonally split heatmap of two matrices
#'
#' Draws a heatmap where each cell is split along a diagonal: the upper
#' triangle shows the corresponding value of `upper`, the lower triangle
#' the value of `lower`. Use for compact paired comparisons — observed vs.
#' predicted, mean vs. variance, correlation vs. significance, train vs.
#' test performance.
#'
#' `biheat()` is the one-shot entry point. It is sugar over the lifecycle
#' [breed()] -> [incubate()] -> [plot()], so:
#'
#' ```
#' biheat(observed, predicted, scale = "shared")
#' ```
#'
#' is exactly:
#'
#' ```
#' breed(observed, predicted) |>
#'   incubate(scale = "shared") |>
#'   plot()
#' ```
#'
#' Use the lifecycle directly when you want to inspect or compose with the
#' paired object — `breed()` returns a `clutch` carrying the aligned
#' matrices, a tidy long form, and comparison statistics (correlation,
#' RMSE, MAE).
#'
#' @param upper Numeric matrix, drawn in the upper triangle. If you pass a
#'   `clutch` here, `lower` must be omitted.
#' @param lower Numeric matrix, drawn in the lower triangle.
#' @param ... Rendering options passed straight to [incubate()]:
#'   `palettes`, `scale`, `split`, `legend_position`, `legend_orientation`,
#'   `show_values`, `value_size`, `grid_colour`, `grid_linewidth`,
#'   `na_colour`, `row_order`, `col_order`, `xlab`, `ylab`, `title`,
#'   `upper_name`, `lower_name`.
#'
#' @return A ggplot object.
#'
#' @examples
#' set.seed(1)
#' u <- matrix(runif(20), 4, 5, dimnames = list(LETTERS[1:4], letters[1:5]))
#' l <- matrix(rnorm(20), 4, 5, dimnames = list(LETTERS[1:4], letters[1:5]))
#'
#' biheat(u, l)
#' biheat(u, l, scale = "shared", split = "up")
#'
#' # equivalent lifecycle form
#' breed(u, l) |> incubate(scale = "shared") |> plot()
#'
#' @seealso [breed()], [incubate()], [plot.clutch()]
#' @export
biheat <- function(upper, lower, ...) {
  if (inherits(upper, "clutch")) {
    if (!missing(lower)) {
      stop_biheat("Pass either a `clutch` or two matrices, not both.")
    }
    return(plot(upper, ...))
  }
  upper_sym <- deparse1(substitute(upper))
  lower_sym <- deparse1(substitute(lower))
  cl <- breed(upper, lower, upper_name = upper_sym, lower_name = lower_sym)
  extras <- list(...)
  if (length(extras) > 0L) cl <- do.call(incubate, c(list(cl), extras))
  plot(cl)
}
