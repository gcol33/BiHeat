#' Paired gradient palettes for BiHeat
#'
#' Bundles two gradient palettes — one for the upper triangle, one for the
#' lower triangle — into a single object you can pass to [biheat()] or
#' [incubate()]. Each side is a character vector of two or more colours,
#' which [scales::gradient_n_pal()] interpolates across `[0, 1]`.
#'
#' @param upper Character vector of colours for the upper-triangle palette.
#' @param lower Character vector of colours for the lower-triangle palette.
#'
#' @return An object of class `palettes`: a list with elements `upper` and
#'   `lower`.
#'
#' @examples
#' palettes(upper = c("white", "darkred"),
#'          lower = c("white", "navy"))
#'
#' @export
palettes <- function(upper = c("white", "red"),
                     lower = c("white", "blue")) {
  if (!is.character(upper) || length(upper) < 2L) {
    stop_biheat("`upper` must be a character vector of length >= 2.")
  }
  if (!is.character(lower) || length(lower) < 2L) {
    stop_biheat("`lower` must be a character vector of length >= 2.")
  }
  structure(list(upper = upper, lower = lower), class = "palettes")
}

#' Print a palettes pair
#' @param x A `palettes` object.
#' @param ... Ignored.
#' @export
#' @keywords internal
print.palettes <- function(x, ...) {
  cat("<palettes>\n")
  cat("  upper: ", paste(x$upper, collapse = " -> "), "\n", sep = "")
  cat("  lower: ", paste(x$lower, collapse = " -> "), "\n", sep = "")
  invisible(x)
}

#' Resolve user palette input into a `palettes` object
#' @keywords internal
resolve_palettes <- function(upper_palette, lower_palette) {
  if (inherits(upper_palette, "palettes")) return(upper_palette)
  palettes(upper = upper_palette, lower = lower_palette)
}
