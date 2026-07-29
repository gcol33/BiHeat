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
#'
#' Accepts what the user-facing entry points accept: a `palettes` object, a
#' bare vector of upper colours optionally paired with `lower_palette`, or
#' `NULL` for the defaults.
#'
#' @keywords internal
as_palettes <- function(x, lower_palette = NULL) {
  if (is.null(x)) {
    if (!is.null(lower_palette)) {
      stop_biheat("`lower_palette` was supplied without `palettes`.")
    }
    return(palettes())
  }
  if (inherits(x, "palettes")) {
    if (!is.null(lower_palette)) {
      stop_biheat("`lower_palette` cannot be combined with a `palettes` object.")
    }
    return(x)
  }
  palettes(upper = x, lower = lower_palette %||% palettes()$lower)
}
