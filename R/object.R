#' Print a biheat_data table
#' @param x A `biheat_data` data frame (internal class on the tidy form).
#' @param n Number of rows to preview.
#' @param ... Ignored.
#' @export
#' @keywords internal
print.biheat_data <- function(x, n = 6L, ...) {
  cat("<biheat_data> ", nrow(x), " cells (",
      length(attr(x, "row_levels")), " x ",
      length(attr(x, "col_levels")), ")\n",
      "  upper = ", attr(x, "upper_name"), "\n",
      "  lower = ", attr(x, "lower_name"), "\n",
      sep = "")
  print(utils::head(as.data.frame(x), n = n))
  if (nrow(x) > n) {
    cat("  ... ", nrow(x) - n, " more rows\n", sep = "")
  }
  invisible(x)
}
