#' A minimal heatmap theme for BiHeat plots
#'
#' Drops panel grids and backgrounds, lays x labels horizontally on the
#' bottom, centres the title block, italicises the caption, and tightens
#' margins. Built on top of [ggplot2::theme_minimal()] — pass a different
#' base via `base` to start from another theme.
#'
#' @param base_size Base font size.
#' @param base A ggplot2 theme to inherit from. Defaults to
#'   [ggplot2::theme_minimal()].
#'
#' @return A ggplot2 `theme` object.
#'
#' @export
theme_biheat <- function(base_size = 11,
                         base = ggplot2::theme_minimal(base_size = base_size)) {
  base +
    ggplot2::theme(
      panel.grid       = ggplot2::element_blank(),
      panel.border     = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      axis.ticks       = ggplot2::element_blank(),
      axis.title       = ggplot2::element_blank(),
      axis.text.x      = ggplot2::element_text(
        size   = ggplot2::rel(0.95),
        margin = ggplot2::margin(t = 4)
      ),
      axis.text.y      = ggplot2::element_text(
        size   = ggplot2::rel(0.95),
        hjust  = 1,
        margin = ggplot2::margin(r = 4)
      ),
      plot.title       = ggplot2::element_text(
        face   = "bold",
        size   = ggplot2::rel(1.4),
        hjust  = 0.5,
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle    = ggplot2::element_text(
        size   = ggplot2::rel(1.05),
        hjust  = 0.5,
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption     = ggplot2::element_text(
        face   = "italic",
        size   = ggplot2::rel(0.85),
        hjust  = 1,
        colour = "grey30",
        margin = ggplot2::margin(t = 10)
      ),
      plot.title.position    = "panel",
      plot.caption.position  = "plot",
      legend.position        = "right",
      legend.justification   = c(0, 1),
      legend.title           = ggplot2::element_text(
        face = "bold",
        size = ggplot2::rel(0.9)
      ),
      legend.text            = ggplot2::element_text(size = ggplot2::rel(0.85)),
      legend.box             = "vertical",
      legend.box.just        = "left",
      legend.spacing.y       = grid::unit(8, "pt"),
      plot.margin            = ggplot2::margin(8, 14, 8, 8)
    )
}
