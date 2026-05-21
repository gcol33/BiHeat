#' @keywords internal
`%||%` <- function(a, b) if (is.null(a)) b else a

#' @keywords internal
stop_biheat <- function(...) {
  stop(paste0(...), call. = FALSE)
}
