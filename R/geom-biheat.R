#' ggplot2 layer for diagonally split heatmap cells
#'
#' A direct-to-ggplot interface for the same rendering [biheat()] performs.
#' Expects a long data frame with one row per cell and `upper` / `lower`
#' aesthetics.
#'
#' Stubbed in this milestone — calling it surfaces a clear "not yet
#' implemented" message so the API is reserved without pretending the
#' rendering works. A full ggproto `GeomBiheat` lands in a later milestone
#' (step 8 in the roadmap).
#'
#' @param mapping Aesthetic mapping. Expected aesthetics are `x`, `y`,
#'   `upper`, `lower`.
#' @param data Long data frame.
#' @param stat,position Standard ggplot2 layer arguments.
#' @param ... Other arguments passed on to the layer (e.g. `colour`,
#'   `linewidth`).
#' @param split `"down"` or `"up"`.
#' @param grid_colour Colour of cell / triangle borders.
#' @param grid_linewidth Border width.
#' @param na_colour Fill for `NA` values.
#' @param show.legend,inherit.aes Standard ggplot2 layer arguments.
#'
#' @return A ggplot2 layer (once implemented).
#'
#' @export
geom_biheat <- function(mapping = NULL, data = NULL,
                        stat = "identity", position = "identity",
                        ...,
                        split = c("down", "up"),
                        grid_colour = "white",
                        grid_linewidth = 0.4,
                        na_colour = "grey90",
                        show.legend = NA,
                        inherit.aes = TRUE) {
  split <- match.arg(split)
  stop_biheat(
    "geom_biheat() is reserved but not yet implemented. ",
    "For milestone 1 use biheat(upper, lower) instead. ",
    "The ggproto layer arrives in the next milestone."
  )
}
