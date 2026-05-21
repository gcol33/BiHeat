#' Breed a pair of matrices into a clutch
#'
#' Combines two matrices into a `clutch`: aligns them on overlapping row /
#' column names when both carry dimnames, computes a compact set of
#' comparison statistics (Pearson and Spearman correlations, RMSE, MAE, NA
#' counts, value ranges), and stores the aligned matrices alongside a tidy
#' long form. The result is the canonical BiHeat input — pass it to
#' [incubate()] to set rendering options and then to [plot()] to draw, or
#' straight to [plot()] (or [biheat()]) for defaults.
#'
#' Alignment rules (`align = "intersect"`, the default):
#'
#' * Both matrices carry rownames and colnames: take the intersection on
#'   each side. The clutch remembers which rows / columns were dropped.
#' * Only one side carries names on a given axis, or neither does:
#'   that axis is aligned by position, which requires identical length.
#' * No overlap on a named axis: error.
#'
#' Pass `align = "by_position"` to skip the name-based logic entirely and
#' require identical shape.
#'
#' @param a,b Matrices (or objects coercible via [as.matrix()]). `a` is
#'   drawn in the upper triangle, `b` in the lower triangle.
#' @param upper_name,lower_name Optional labels. When `NULL`, BiHeat reads
#'   the symbol names you passed in via [substitute()], so
#'   `breed(observed, predicted)` records `"observed"` and `"predicted"`
#'   automatically.
#' @param align `"intersect"` (default) or `"by_position"`.
#'
#' @return A `clutch`: a list with `upper`, `lower`, `data`, `meta`,
#'   `align`, `align_report`, `upper_name`, `lower_name`, `config`.
#'
#' @examples
#' set.seed(1)
#' species <- LETTERS[1:6]
#' sites   <- letters[1:5]
#' observed  <- matrix(runif(30), 6, 5, dimnames = list(species, sites))
#' predicted <- observed + matrix(rnorm(30, sd = 0.1), 6, 5,
#'                                dimnames = list(species, sites))
#'
#' clutch <- breed(observed, predicted)
#' clutch
#' plot(clutch)
#'
#' @seealso [incubate()], [biheat()]
#' @export
breed <- function(a, b,
                  upper_name = NULL,
                  lower_name = NULL,
                  align = c("intersect", "by_position")) {

  if (is.null(upper_name)) upper_name <- deparse1(substitute(a))
  if (is.null(lower_name)) lower_name <- deparse1(substitute(b))

  align <- match.arg(align)

  if (!is.matrix(a)) a <- as.matrix(a)
  if (!is.matrix(b)) b <- as.matrix(b)
  if (!is.numeric(a)) stop_biheat("`a` must be a numeric matrix.")
  if (!is.numeric(b)) stop_biheat("`b` must be a numeric matrix.")

  aligned <- align_matrices(a, b, align = align)
  tidy <- as_biheat_data(aligned$a, aligned$b,
                         upper_name = upper_name,
                         lower_name = lower_name)
  meta <- compare_pair(aligned$a, aligned$b)

  structure(
    list(
      upper        = aligned$a,
      lower        = aligned$b,
      data         = tidy,
      meta         = meta,
      align        = align,
      align_report = aligned$report,
      upper_name   = upper_name,
      lower_name   = lower_name,
      config       = list()
    ),
    class = "clutch"
  )
}

#' Align two matrices on overlapping dimnames
#' @keywords internal
align_matrices <- function(a, b, align = c("intersect", "by_position")) {
  align <- match.arg(align)

  if (align == "by_position") {
    if (!identical(dim(a), dim(b))) {
      stop_biheat(sprintf(
        "Matrices have different dimensions (%dx%d vs %dx%d); cannot align by position.",
        nrow(a), ncol(a), nrow(b), ncol(b)
      ))
    }
    return(list(a = a, b = b,
                report = list(mode = "by_position",
                              rows_kept = nrow(a), cols_kept = ncol(a),
                              rows_dropped_a = character(), rows_dropped_b = character(),
                              cols_dropped_a = character(), cols_dropped_b = character())))
  }

  both_rn <- !is.null(rownames(a)) && !is.null(rownames(b))
  both_cn <- !is.null(colnames(a)) && !is.null(colnames(b))

  if (!both_rn && !both_cn) {
    return(align_matrices(a, b, align = "by_position"))
  }

  if (!both_rn && nrow(a) != nrow(b)) {
    stop_biheat("Row dimensions differ and not both matrices carry rownames.")
  }
  if (!both_cn && ncol(a) != ncol(b)) {
    stop_biheat("Column dimensions differ and not both matrices carry colnames.")
  }

  orig_rn_a <- rownames(a); orig_rn_b <- rownames(b)
  orig_cn_a <- colnames(a); orig_cn_b <- colnames(b)

  rn <- if (both_rn) intersect(orig_rn_a, orig_rn_b) else NULL
  cn <- if (both_cn) intersect(orig_cn_a, orig_cn_b) else NULL

  if (both_rn && length(rn) == 0L) {
    stop_biheat("No overlapping row names between `a` and `b`.")
  }
  if (both_cn && length(cn) == 0L) {
    stop_biheat("No overlapping column names between `a` and `b`.")
  }

  if (both_rn) {
    a <- a[rn, , drop = FALSE]
    b <- b[rn, , drop = FALSE]
  }
  if (both_cn) {
    a <- a[, cn, drop = FALSE]
    b <- b[, cn, drop = FALSE]
  }

  list(
    a = a, b = b,
    report = list(
      mode           = "intersect",
      rows_kept      = nrow(a),
      cols_kept      = ncol(a),
      rows_dropped_a = if (both_rn) setdiff(orig_rn_a, rn) else character(),
      rows_dropped_b = if (both_rn) setdiff(orig_rn_b, rn) else character(),
      cols_dropped_a = if (both_cn) setdiff(orig_cn_a, cn) else character(),
      cols_dropped_b = if (both_cn) setdiff(orig_cn_b, cn) else character()
    )
  )
}

#' Comparison statistics between two aligned matrices
#' @keywords internal
compare_pair <- function(a, b) {
  finite <- !is.na(a) & !is.na(b)
  out <- list(
    n_cells      = length(a),
    n_finite     = sum(finite),
    n_na         = sum(!finite),
    upper_range  = if (any(!is.na(a))) range(a, na.rm = TRUE) else c(NA_real_, NA_real_),
    lower_range  = if (any(!is.na(b))) range(b, na.rm = TRUE) else c(NA_real_, NA_real_),
    shared_range = if (any(!is.na(c(a, b)))) range(c(a, b), na.rm = TRUE) else c(NA_real_, NA_real_)
  )
  if (sum(finite) >= 2L) {
    av <- as.vector(a)[as.vector(finite)]
    bv <- as.vector(b)[as.vector(finite)]
    out$pearson  <- stats::cor(av, bv)
    out$spearman <- suppressWarnings(stats::cor(av, bv, method = "spearman"))
    out$rmse     <- sqrt(mean((av - bv) ^ 2))
    out$mae      <- mean(abs(av - bv))
  }
  out
}

#' Print a clutch
#' @param x A `clutch`.
#' @param ... Ignored.
#' @export
#' @keywords internal
print.clutch <- function(x, ...) {
  cat("<clutch>\n")
  cat("  upper: ", x$upper_name, " (", paste(dim(x$upper), collapse = " x "), ")\n", sep = "")
  cat("  lower: ", x$lower_name, " (", paste(dim(x$lower), collapse = " x "), ")\n", sep = "")
  cat("  align: ", x$align_report$mode,
      "  (", x$align_report$rows_kept, " rows x ", x$align_report$cols_kept, " cols kept)\n",
      sep = "")
  rd <- length(union(x$align_report$rows_dropped_a, x$align_report$rows_dropped_b))
  cd <- length(union(x$align_report$cols_dropped_a, x$align_report$cols_dropped_b))
  if (rd + cd > 0L) {
    cat("  dropped: ", rd, " rows, ", cd, " cols\n", sep = "")
  }

  meta <- x$meta
  cat("  cells: ", meta$n_finite, " finite / ",
      meta$n_cells, " total (", meta$n_na, " NA)\n", sep = "")
  if (!is.null(meta$pearson)) {
    fmt <- function(v) formatC(v, digits = 3, format = "g")
    cat("  pearson: ", fmt(meta$pearson),
        "   rmse: ", fmt(meta$rmse),
        "   mae: ", fmt(meta$mae), "\n", sep = "")
  }
  if (length(x$config) > 0L) {
    flat <- vapply(names(x$config), function(nm) {
      v <- x$config[[nm]]
      if (is.character(v) && length(v) == 1L) sprintf("%s=%s", nm, v)
      else if (is.logical(v) && length(v) == 1L) sprintf("%s=%s", nm, v)
      else if (is.numeric(v) && length(v) == 1L) sprintf("%s=%s", nm, formatC(v))
      else sprintf("%s=<set>", nm)
    }, character(1))
    cat("  config: ", paste(flat, collapse = ", "), "\n", sep = "")
  }
  invisible(x)
}

#' Plot a clutch (S3 method for plot())
#'
#' Renders a [breed()]ed clutch as a diagonally split heatmap. Reads any
#' configuration set by [incubate()] and fills in defaults for the rest.
#'
#' @param x A `clutch`.
#' @param y Ignored (required by the `plot()` S3 signature).
#' @param ... Additional rendering options. Treated as a final [incubate()]
#'   pass before drawing.
#'
#' @return A ggplot object.
#' @export
plot.clutch <- function(x, y, ...) {
  extras <- list(...)
  if (length(extras) > 0L) x <- do.call(incubate, c(list(x), extras))
  render_clutch(x)
}
