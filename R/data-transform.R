#' Tidy two matrices into one row per cell
#'
#' Internal helper used by [breed()]. Validates inputs, then returns a long
#' data frame with columns `row`, `col`, `i`, `j`, `upper`, `lower`. Row /
#' column orders are preserved on attributes.
#'
#' @keywords internal
as_biheat_data <- function(upper, lower,
                           upper_name = "upper",
                           lower_name = "lower") {
  if (!is.matrix(upper)) upper <- as.matrix(upper)
  if (!is.matrix(lower)) lower <- as.matrix(lower)

  if (!is.numeric(upper)) stop_biheat("`upper` must be a numeric matrix.")
  if (!is.numeric(lower)) stop_biheat("`lower` must be a numeric matrix.")

  if (!identical(dim(upper), dim(lower))) {
    stop_biheat(sprintf(
      "`upper` and `lower` must have identical dimensions (got %dx%d and %dx%d).",
      nrow(upper), ncol(upper), nrow(lower), ncol(lower)
    ))
  }

  rn <- rownames(upper) %||% rownames(lower) %||% paste0("r", seq_len(nrow(upper)))
  cn <- colnames(upper) %||% colnames(lower) %||% paste0("c", seq_len(ncol(upper)))

  grid <- expand.grid(i = seq_len(nrow(upper)),
                      j = seq_len(ncol(upper)),
                      KEEP.OUT.ATTRS = FALSE)

  out <- data.frame(
    row = rn[grid$i],
    col = cn[grid$j],
    i = grid$i,
    j = grid$j,
    upper = upper[cbind(grid$i, grid$j)],
    lower = lower[cbind(grid$i, grid$j)],
    stringsAsFactors = FALSE
  )

  attr(out, "upper_name") <- upper_name
  attr(out, "lower_name") <- lower_name
  attr(out, "row_levels") <- rn
  attr(out, "col_levels") <- cn

  class(out) <- c("biheat_data", "data.frame")
  out
}

#' Expand cell-level data into triangle polygon coordinates
#'
#' Internal helper shared by the clutch renderer and [geom_biheat()]. Given a
#' data frame of cell centres, returns a long data frame of polygon vertices
#' suitable for [grid::polygonGrob()] or [ggplot2::geom_polygon()]. Two
#' polygons are produced per input row: one for the upper-value triangle and
#' one for the lower-value triangle.
#'
#' Coordinates follow the display convention, so `y` grows upward: for
#' `split = "down"` the cell is cut from its top-left to its bottom-right
#' corner and the upper triangle is the one above that cut.
#'
#' @param data A data frame with numeric `x`, `y` (cell centres) and `upper`,
#'   `lower` (cell values). Optional numeric `width` and `height` columns give
#'   per-cell footprints; both default to `1`.
#' @param split One of `"down"` (top-left to bottom-right diagonal) or
#'   `"up"` (bottom-left to top-right diagonal).
#' @param inset Numeric in `[0, 0.5)`. Shrinks each cell's footprint by this
#'   fraction of its width and height on every side, opening a gap between
#'   neighbouring cells. `0` gives contiguous cells; `0.04` gives an ~8% gap.
#'
#' @return A data frame with columns `x`, `y`, `polygon_id`, `which`,
#'   `value`, `.row` (the index of the source row in `data`).
#'
#' @keywords internal
build_triangles <- function(data, split = c("down", "up"), inset = 0) {
  split <- match.arg(split)
  if (!is.numeric(inset) || length(inset) != 1L || inset < 0 || inset >= 0.5) {
    stop_biheat("`inset` must be a single number in [0, 0.5).")
  }

  n <- nrow(data)
  if (n == 0L) {
    return(data.frame(
      x = numeric(0), y = numeric(0),
      polygon_id = character(0), which = character(0),
      value = numeric(0), .row = integer(0)
    ))
  }

  x <- data$x
  y <- data$y
  w <- data$width  %||% rep(1, n)
  h <- data$height %||% rep(1, n)

  half_w <- w / 2 - inset * w
  half_h <- h / 2 - inset * h

  BL_x <- x - half_w; BL_y <- y - half_h
  BR_x <- x + half_w; BR_y <- y - half_h
  TL_x <- x - half_w; TL_y <- y + half_h
  TR_x <- x + half_w; TR_y <- y + half_h

  if (split == "down") {
    # Diagonal TL <-> BR. The upper triangle sits above it, on the right.
    upper_x <- rbind(TL_x, TR_x, BR_x)
    upper_y <- rbind(TL_y, TR_y, BR_y)
    lower_x <- rbind(TL_x, BL_x, BR_x)
    lower_y <- rbind(TL_y, BL_y, BR_y)
  } else {
    # Diagonal BL <-> TR. The upper triangle sits above it, on the left.
    upper_x <- rbind(BL_x, TL_x, TR_x)
    upper_y <- rbind(BL_y, TL_y, TR_y)
    lower_x <- rbind(BL_x, BR_x, TR_x)
    lower_y <- rbind(BL_y, BR_y, TR_y)
  }

  upper_df <- data.frame(
    x = as.vector(upper_x),
    y = as.vector(upper_y),
    polygon_id = rep(paste0("u_", seq_len(n)), each = 3L),
    which = "upper",
    value = rep(data$upper, each = 3L),
    .row = rep(seq_len(n), each = 3L),
    stringsAsFactors = FALSE
  )
  lower_df <- data.frame(
    x = as.vector(lower_x),
    y = as.vector(lower_y),
    polygon_id = rep(paste0("l_", seq_len(n)), each = 3L),
    which = "lower",
    value = rep(data$lower, each = 3L),
    .row = rep(seq_len(n), each = 3L),
    stringsAsFactors = FALSE
  )

  rbind(upper_df, lower_df)
}

#' Map numeric values to colours using a gradient palette
#'
#' Internal helper. Rescales values to `[0, 1]` against a numeric range and
#' applies a gradient palette function. Out-of-range values are clamped.
#' `NA` values receive `na_colour`. A degenerate range (`min == max`) maps
#' every non-`NA` value to the palette midpoint.
#'
#' @keywords internal
map_colour <- function(x, rng, pal_fn, na_colour) {
  out <- rep(na_colour, length(x))
  finite <- !is.na(x)
  if (!any(finite)) return(out)

  if (rng[1] == rng[2]) {
    out[finite] <- pal_fn(0.5)
    return(out)
  }

  t <- (x[finite] - rng[1]) / (rng[2] - rng[1])
  t <- pmin(pmax(t, 0), 1)
  out[finite] <- pal_fn(t)
  out
}
