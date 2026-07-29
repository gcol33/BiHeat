#' ggplot2 layer for diagonally split heatmap cells
#'
#' A direct-to-ggplot interface for the drawing [biheat()] performs. Expects
#' a long data frame with one row per cell and `upper` / `lower` aesthetics
#' holding the two values. Each cell is drawn as two triangles: `upper` above
#' the diagonal, `lower` below it.
#'
#' The layer carries its own pair of gradient palettes and maps values to
#' colours itself, so the two triangles keep independent colour ranges inside
#' a single ggplot. Neither side consumes the `fill` scale, which leaves it
#' free for other layers. Add a key with [bi_legend()], or use [biheat()] when
#' you want the legend built for you.
#'
#' @param mapping Aesthetic mapping. Required aesthetics are `x`, `y`,
#'   `upper`, `lower`; `width`, `height`, `colour`, `linewidth`, `linetype`
#'   and `alpha` are optional.
#' @param data Long data frame, one row per cell.
#' @param stat,position Standard ggplot2 layer arguments.
#' @param ... Other arguments passed on to [ggplot2::layer()], including
#'   fixed aesthetics such as `colour` or `linewidth`.
#' @param split `"down"` (top-left to bottom-right diagonal) or `"up"`.
#' @param palettes A [palettes()] object, or a character vector of upper
#'   colours paired with `lower_palette`. Defaults to white-to-red over
#'   white-to-blue.
#' @param lower_palette Optional companion to a bare `palettes` vector.
#' @param upper_range,lower_range Numeric length-2 value ranges the palettes
#'   are stretched across. Default to the range of the data in each triangle.
#'   Pass the same value to both for a shared scale.
#' @param cell_inset Numeric in `[0, 0.5)`. Shrinks each cell on every side to
#'   leave a gap between neighbours.
#' @param na_colour Fill for `NA` values.
#' @param show.legend,inherit.aes Standard ggplot2 layer arguments.
#'
#' @return A ggplot2 layer.
#'
#' @examples
#' set.seed(1)
#' cells <- expand.grid(site = letters[1:5], species = LETTERS[1:4])
#' cells$observed  <- runif(20)
#' cells$predicted <- runif(20)
#'
#' library(ggplot2)
#' ggplot(cells, aes(site, species, upper = observed, lower = predicted)) +
#'   geom_biheat() +
#'   theme_biheat()
#'
#' @seealso [biheat()], [bi_legend()]
#' @export
geom_biheat <- function(mapping = NULL, data = NULL,
                        stat = "identity", position = "identity",
                        ...,
                        split = c("down", "up"),
                        palettes = NULL,
                        lower_palette = NULL,
                        upper_range = NULL,
                        lower_range = NULL,
                        cell_inset = 0.04,
                        na_colour = "grey90",
                        show.legend = NA,
                        inherit.aes = TRUE) {
  split <- match.arg(split)
  pal <- as_palettes(palettes, lower_palette)
  check_range(upper_range, "upper_range")
  check_range(lower_range, "lower_range")

  ggplot2::layer(
    geom        = GeomBiheat,
    mapping     = mapping,
    data        = data,
    stat        = stat,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      split       = split,
      palettes    = pal,
      upper_range = upper_range,
      lower_range = lower_range,
      cell_inset  = cell_inset,
      na_colour   = na_colour,
      ...
    )
  )
}

#' Validate an optional length-2 numeric range
#' @keywords internal
check_range <- function(x, arg) {
  if (is.null(x)) return(invisible(NULL))
  if (!is.numeric(x) || length(x) != 2L || any(!is.finite(x))) {
    stop_biheat(sprintf("`%s` must be a finite numeric vector of length 2.", arg))
  }
  invisible(NULL)
}

#' @rdname geom_biheat
#' @format NULL
#' @usage NULL
#' @export
GeomBiheat <- ggplot2::ggproto(
  "GeomBiheat", ggplot2::Geom,

  required_aes = c("x", "y", "upper", "lower"),

  default_aes = ggplot2::aes(
    colour    = NA,
    linewidth = 0.4,
    linetype  = 1,
    alpha     = NA,
    width     = NA,
    height    = NA
  ),

  # A missing value belongs in one triangle, not the whole cell: keep the row
  # and let `na_colour` speak for it. Only a missing position drops a cell.
  handle_na = function(self, data, params) {
    ggplot2::remove_missing(data, params$na.rm %||% FALSE,
                            c("x", "y"), "geom_biheat")
  },

  setup_data = function(data, params) {
    data$width <- fill_extent(data$width, params$width, data$x)
    data$height <- fill_extent(data$height, params$height, data$y)
    data$xmin <- data$x - data$width / 2
    data$xmax <- data$x + data$width / 2
    data$ymin <- data$y - data$height / 2
    data$ymax <- data$y + data$height / 2
    data
  },

  draw_panel = function(self, data, panel_params, coord,
                        split = "down", palettes = NULL,
                        upper_range = NULL, lower_range = NULL,
                        cell_inset = 0.04, na_colour = "grey90",
                        lineend = "butt", linejoin = "mitre") {
    pal <- as_palettes(palettes, NULL)
    upper_rng <- upper_range %||% safe_range(data$upper)
    lower_rng <- lower_range %||% safe_range(data$lower)

    tri <- build_triangles(data, split = split, inset = cell_inset)
    is_upper <- tri$which == "upper"

    fill <- rep(na_colour, nrow(tri))
    fill[is_upper] <- map_colour(tri$value[is_upper], upper_rng,
                                 scales::gradient_n_pal(pal$upper), na_colour)
    fill[!is_upper] <- map_colour(tri$value[!is_upper], lower_rng,
                                  scales::gradient_n_pal(pal$lower), na_colour)

    tri$fill      <- fill
    tri$colour    <- data$colour[tri$.row]
    tri$linewidth <- data$linewidth[tri$.row]
    tri$linetype  <- data$linetype[tri$.row]
    tri$alpha     <- data$alpha[tri$.row]
    tri$group     <- tri$polygon_id

    munched <- ggplot2::coord_munch(coord, tri, panel_params, is_closed = TRUE)
    first <- !duplicated(munched$group)

    grid::polygonGrob(
      munched$x, munched$y,
      id = match(munched$group, unique(munched$group)),
      default.units = "native",
      gp = grid::gpar(
        fill     = scales::alpha(munched$fill[first], munched$alpha[first]),
        col      = munched$colour[first],
        lwd      = munched$linewidth[first] * ggplot2::.pt,
        lty      = munched$linetype[first],
        lineend  = lineend,
        linejoin = linejoin
      )
    )
  },

  draw_key = ggplot2::draw_key_polygon
)

#' Resolve a cell width / height column
#'
#' Takes the mapped aesthetic, then a fixed parameter, then the resolution of
#' the position values, whichever comes first.
#'
#' @keywords internal
fill_extent <- function(aes_value, param, position) {
  res <- ggplot2::resolution(position, zero = FALSE)
  out <- aes_value %||% rep(NA_real_, length(position))
  out[is.na(out)] <- param %||% res
  out
}

#' Range of a numeric vector, robust to all-`NA` input
#' @keywords internal
safe_range <- function(x) {
  if (!any(!is.na(x))) return(c(0, 1))
  range(x, na.rm = TRUE)
}
