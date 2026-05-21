#' Swap which matrix is on top
#'
#' Exchanges the upper and lower triangles of a clutch.
#'
#' @param x A `clutch` from [breed()].
#'
#' @return A `clutch` with `upper` / `lower` exchanged and their `*_name`
#'   slots swapped.
#'
#' @examples
#' u <- matrix(1:6, 2, 3); l <- matrix(7:12, 2, 3)
#' breed(u, l, "obs", "pred") |> switch_sides()
#'
#' @export
switch_sides <- function(x) {
  if (!inherits(x, "clutch")) {
    stop_biheat("`switch_sides()` expects a clutch (from `breed()`).")
  }
  out <- x
  out$upper      <- x$lower
  out$lower      <- x$upper
  out$upper_name <- x$lower_name
  out$lower_name <- x$upper_name

  d <- x$data
  d$upper <- x$data$lower
  d$lower <- x$data$upper
  attr(d, "upper_name") <- x$lower_name
  attr(d, "lower_name") <- x$upper_name
  out$data <- d

  meta <- x$meta
  meta$upper_range <- x$meta$lower_range
  meta$lower_range <- x$meta$upper_range
  out$meta <- meta

  out
}

#' Flip the diagonal direction
#'
#' Toggles `split = "down"` <-> `split = "up"` on a clutch. When no `split`
#' has been set, picks `"up"` (since the rendering default is `"down"`).
#'
#' @param x A `clutch`.
#'
#' @return A `clutch`.
#'
#' @export
straighten <- function(x) {
  if (!inherits(x, "clutch")) {
    stop_biheat("`straighten()` expects a clutch (from `breed()`).")
  }
  current <- x$config$split %||% "down"
  incubate(x, split = if (identical(current, "down")) "up" else "down")
}

#' Toggle between shared and separate colour scales
#'
#' @param x A `clutch`.
#' @param value Optional explicit `"shared"` / `"separate"`. If omitted,
#'   toggles between the two.
#'
#' @return A `clutch`.
#'
#' @export
bothways <- function(x, value = NULL) {
  if (!inherits(x, "clutch")) {
    stop_biheat("`bothways()` expects a clutch (from `breed()`).")
  }
  if (is.null(value)) {
    current <- x$config$scale %||% "separate"
    value <- if (identical(current, "shared")) "separate" else "shared"
  } else {
    value <- match.arg(value, c("shared", "separate"))
  }
  incubate(x, scale = value)
}

#' Extract the tidy data from a clutch or rendered plot
#'
#' Pulls out the per-cell long table — useful for piping into another
#' visualisation or for inspection.
#'
#' @param x A `clutch`, or a ggplot returned by [biheat()] / [plot.clutch()].
#'
#' @return A data frame with columns `row`, `col`, `i`, `j`, `upper`, `lower`.
#'
#' @export
comes_out <- function(x) {
  if (inherits(x, "clutch")) {
    return(x$data)
  }
  spec <- attr(x, "clutch_spec")
  if (!is.null(spec) && !is.null(spec$data)) {
    return(spec$data)
  }
  stop_biheat("`comes_out()` expects a clutch or a BiHeat ggplot.")
}
