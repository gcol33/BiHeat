#' Render a configured clutch into a plot
#'
#' Internal renderer. Reads `x$config`, fills any unset slot from
#' [clutch_defaults()], validates enum values, and builds a ggplot with
#' two fill scales (one per triangle) via [ggnewscale::new_scale_fill()].
#' Returns a `biheat_plot` object: a gtable that wraps the ggplot grob plus
#' the optional split-tile key glyph injected into the legend column.
#'
#' @keywords internal
render_clutch <- function(x) {
  cfg <- modifyList(clutch_defaults(), x$config %||% list())

  scale              <- match.arg(cfg$scale,              c("separate", "shared"))
  split              <- match.arg(cfg$split,              c("down", "up"))
  legend_position    <- match.arg(cfg$legend_position,    c("right", "bottom", "none"))
  legend_orientation <- match.arg(cfg$legend_orientation, c("vertical", "horizontal"))
  pal                <- resolve_palettes(cfg$palettes, NULL)

  row_levels <- attr(x$data, "row_levels")
  col_levels <- attr(x$data, "col_levels")

  if (!is.null(cfg$row_order)) {
    if (!setequal(cfg$row_order, row_levels)) {
      stop_biheat("`row_order` must be a permutation of the clutch's row labels.")
    }
    row_levels <- as.character(cfg$row_order)
  }
  if (!is.null(cfg$col_order)) {
    if (!setequal(cfg$col_order, col_levels)) {
      stop_biheat("`col_order` must be a permutation of the clutch's column labels.")
    }
    col_levels <- as.character(cfg$col_order)
  }

  d <- x$data
  d$i <- match(d$row, row_levels)
  d$j <- match(d$col, col_levels)

  inset <- cfg$cell_inset %||% 0
  tri <- build_triangles(d, split = split, inset = inset)
  upper_df <- tri[tri$which == "upper", , drop = FALSE]
  lower_df <- tri[tri$which == "lower", , drop = FALSE]

  if (scale == "shared") {
    rng <- range(c(x$upper, x$lower), na.rm = TRUE)
    upper_rng <- rng
    lower_rng <- rng
  } else {
    upper_rng <- range(x$upper, na.rm = TRUE)
    lower_rng <- range(x$lower, na.rm = TRUE)
  }

  upper_axis <- nice_axis(upper_rng)
  lower_axis <- nice_axis(lower_rng)

  guide_dir <- if (legend_orientation == "horizontal") "horizontal" else "vertical"
  upper_guide <- bar_guide(sprintf("%s (upper triangle)", x$upper_name), guide_dir, order = 1L)
  lower_guide <- bar_guide(sprintf("%s (lower triangle)", x$lower_name), guide_dir, order = 2L)

  grid_colour <- cfg$grid_colour
  if (is.null(grid_colour)) grid_colour <- NA
  grid_lw <- cfg$grid_linewidth %||% 0

  p <- ggplot2::ggplot() +
    ggplot2::geom_polygon(
      data    = upper_df,
      mapping = ggplot2::aes(
        x = .data$x, y = .data$y,
        group = .data$polygon_id, fill = .data$value
      ),
      colour    = grid_colour,
      linewidth = grid_lw
    ) +
    ggplot2::scale_fill_gradientn(
      name      = sprintf("%s (upper triangle)", x$upper_name),
      colours   = pal$upper,
      limits    = upper_axis$limits,
      breaks    = upper_axis$breaks,
      na.value  = cfg$na_colour,
      oob       = scales::squish,
      guide     = upper_guide
    ) +
    ggnewscale::new_scale_fill() +
    ggplot2::geom_polygon(
      data    = lower_df,
      mapping = ggplot2::aes(
        x = .data$x, y = .data$y,
        group = .data$polygon_id, fill = .data$value
      ),
      colour    = grid_colour,
      linewidth = grid_lw
    ) +
    ggplot2::scale_fill_gradientn(
      name      = sprintf("%s (lower triangle)", x$lower_name),
      colours   = pal$lower,
      limits    = lower_axis$limits,
      breaks    = lower_axis$breaks,
      na.value  = cfg$na_colour,
      oob       = scales::squish,
      guide     = lower_guide
    ) +
    ggplot2::scale_x_continuous(
      breaks = seq_along(col_levels),
      labels = col_levels,
      expand = ggplot2::expansion(add = 0.5 - inset / 2)
    ) +
    ggplot2::scale_y_reverse(
      breaks = seq_along(row_levels),
      labels = row_levels,
      expand = ggplot2::expansion(add = 0.5 - inset / 2)
    ) +
    theme_biheat() +
    ggplot2::theme(legend.position = legend_position) +
    ggplot2::labs(
      x        = cfg$xlab,
      y        = cfg$ylab,
      title    = cfg$title,
      subtitle = cfg$subtitle,
      caption  = cfg$caption
    )

  if (isTRUE(cfg$show_values)) {
    centroids <- triangle_centroids(tri)
    p <- p + ggplot2::geom_text(
      data    = centroids,
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
      size    = cfg$value_size,
      inherit.aes = FALSE
    )
  }

  spec <- list(
    upper_name         = x$upper_name,
    lower_name         = x$lower_name,
    palettes           = pal,
    scale              = scale,
    split              = split,
    legend_position    = legend_position,
    legend_orientation = legend_orientation,
    upper_range        = upper_rng,
    lower_range        = lower_rng,
    na_colour          = cfg$na_colour,
    show_key           = isTRUE(cfg$show_key %||% TRUE),
    data               = x$data
  )

  attr(p, "clutch_spec") <- spec

  if (legend_position != "none" && isTRUE(spec$show_key)) {
    p <- inject_key_glyph(p, spec)
  }
  p
}

#' Build a styled colourbar guide
#' @keywords internal
bar_guide <- function(title, direction = c("vertical", "horizontal"), order = 0L) {
  direction <- match.arg(direction)
  ggplot2::guide_colourbar(
    title           = title,
    title.position  = "top",
    title.hjust     = 0,
    direction       = "horizontal",
    barwidth        = grid::unit(4.2, "cm"),
    barheight       = grid::unit(0.42, "cm"),
    nbin            = 256,
    ticks           = TRUE,
    ticks.colour    = "grey25",
    ticks.linewidth = 0.6,
    frame.colour    = "grey45",
    frame.linewidth = 0.4,
    label.position  = "bottom",
    label.hjust     = 0.5,
    order           = order
  )
}

#' Compute round-number limits + breaks for a colour bar
#'
#' Picks short, pretty tick labels (typically 3 of them) and stretches the
#' bar's limits out to the first / last break so the ticks line up with the
#' end of the bar instead of floating somewhere inside it.
#'
#' @keywords internal
nice_axis <- function(rng) {
  if (length(rng) != 2L || any(!is.finite(rng))) {
    return(list(limits = rng, breaks = ggplot2::waiver()))
  }
  if (rng[1] == rng[2]) {
    eps <- if (rng[1] == 0) 1 else abs(rng[1])
    return(list(limits = c(rng[1] - eps, rng[1] + eps), breaks = rng[1]))
  }
  brk <- pretty(rng, n = 2L)
  brk <- brk[brk >= rng[1] - 1e-9 * diff(rng) &
             brk <= rng[2] + 1e-9 * diff(rng)]
  if (length(brk) < 2L) brk <- pretty(rng, n = 3L)
  lims <- range(brk[1L], brk[length(brk)], rng)
  list(limits = lims, breaks = brk)
}

#' Inject a split-tile key glyph below the legend colourbars
#'
#' Converts a ggplot to a gtable, builds a [key_glyph_grob()] explaining
#' which triangle is which, and inserts it into the guide-box gtable.
#' Returns a `biheat_plot` (gtable subclass).
#'
#' @keywords internal
inject_key_glyph <- function(p, spec) {
  g <- ggplot2::ggplotGrob(p)

  guide_idx <- which(g$layout$name == "guide-box-right")
  if (length(guide_idx) == 0L) {
    guide_idx <- which(g$layout$name == "guide-box")
  }
  if (length(guide_idx) == 0L) {
    class(g) <- c("biheat_plot", class(g))
    attr(g, "clutch_spec") <- spec
    return(g)
  }

  guide_box <- g$grobs[[guide_idx[1]]]
  key <- key_glyph_grob(
    upper_name = spec$upper_name,
    lower_name = spec$lower_name,
    upper_palette = spec$palettes$upper,
    lower_palette = spec$palettes$lower,
    split      = spec$split
  )

  if (inherits(guide_box, "gtable")) {
    n_rows <- nrow(guide_box)
    guide_box <- gtable::gtable_add_rows(
      guide_box,
      heights = grid::unit(0.4, "cm"),
      pos = n_rows
    )
    guide_box <- gtable::gtable_add_rows(
      guide_box,
      heights = grid::unit(2.6, "cm"),
      pos = n_rows + 1L
    )
    guide_box <- gtable::gtable_add_grob(
      guide_box,
      grobs = key,
      t     = n_rows + 2L,
      l     = 1L,
      r     = ncol(guide_box),
      name  = "biheat-key"
    )
    g$grobs[[guide_idx[1]]] <- guide_box
  }

  class(g) <- c("biheat_plot", class(g))
  attr(g, "clutch_spec") <- spec
  g
}

#' Build the split-tile key grob
#'
#' Returns a grid grob: a small split square with the upper triangle in the
#' upper palette and the lower triangle in the lower palette, plus two
#' callout lines to labels "<upper> (upper)" / "<lower> (lower)".
#'
#' @keywords internal
key_glyph_grob <- function(upper_name = "A",
                           lower_name = "B",
                           upper_palette = c("white", "red"),
                           lower_palette = c("white", "blue"),
                           split = c("down", "up")) {
  split <- match.arg(split)

  up_col <- scales::gradient_n_pal(upper_palette)(0.9)
  lo_col <- scales::gradient_n_pal(lower_palette)(0.9)

  # Fixed-size square on the left so the glyph reads the same no matter how
  # tall the legend cell is. Leader lines + labels sit to its right in npc.
  sq_side  <- grid::unit(1.25, "cm")
  sq_left  <- grid::unit(0.25, "cm")
  sq_vp <- grid::viewport(
    x = sq_left, y = grid::unit(0.5, "npc"),
    width = sq_side, height = sq_side,
    just = c("left", "centre"),
    name = "biheat-key-square"
  )

  if (split == "down") {
    up_xs <- c(0, 1, 1); up_ys <- c(1, 1, 0)
    lo_xs <- c(0, 0, 1); lo_ys <- c(1, 0, 0)
    upper_anchor_x <- 0.70; upper_anchor_y <- 0.78
    lower_anchor_x <- 0.30; lower_anchor_y <- 0.22
  } else {
    up_xs <- c(0, 1, 0); up_ys <- c(1, 1, 0)
    lo_xs <- c(1, 1, 0); lo_ys <- c(1, 0, 0)
    upper_anchor_x <- 0.30; upper_anchor_y <- 0.78
    lower_anchor_x <- 0.70; lower_anchor_y <- 0.22
  }

  upper_tri <- grid::polygonGrob(
    x = up_xs, y = up_ys,
    gp = grid::gpar(fill = up_col, col = "white", lwd = 0.8),
    vp = sq_vp
  )
  lower_tri <- grid::polygonGrob(
    x = lo_xs, y = lo_ys,
    gp = grid::gpar(fill = lo_col, col = "white", lwd = 0.8),
    vp = sq_vp
  )

  # Anchor coords (npc inside the square viewport) translated back into the
  # parent viewport's units so leader lines can run from inside the square
  # out to cm-positioned labels.
  anchor_xy <- function(ax, ay) {
    x_parent <- sq_left + sq_side * ax
    y_parent <- grid::unit(0.5, "npc") + sq_side * (ay - 0.5)
    list(x = x_parent, y = y_parent)
  }
  up_anchor <- anchor_xy(upper_anchor_x, upper_anchor_y)
  lo_anchor <- anchor_xy(lower_anchor_x, lower_anchor_y)

  elbow_x <- sq_left + sq_side + grid::unit(0.45, "cm")
  label_x <- sq_left + sq_side + grid::unit(0.65, "cm")
  upper_y <- grid::unit(0.5, "npc") + grid::unit(0.5, "cm")
  lower_y <- grid::unit(0.5, "npc") - grid::unit(0.5, "cm")

  upper_leader_diag <- grid::segmentsGrob(
    x0 = up_anchor$x, y0 = up_anchor$y,
    x1 = elbow_x,     y1 = upper_y,
    gp = grid::gpar(col = "grey30", lwd = 0.6)
  )
  upper_leader_h <- grid::segmentsGrob(
    x0 = elbow_x, y0 = upper_y,
    x1 = label_x, y1 = upper_y,
    gp = grid::gpar(col = "grey30", lwd = 0.6)
  )
  lower_leader_diag <- grid::segmentsGrob(
    x0 = lo_anchor$x, y0 = lo_anchor$y,
    x1 = elbow_x,     y1 = lower_y,
    gp = grid::gpar(col = "grey30", lwd = 0.6)
  )
  lower_leader_h <- grid::segmentsGrob(
    x0 = elbow_x, y0 = lower_y,
    x1 = label_x, y1 = lower_y,
    gp = grid::gpar(col = "grey30", lwd = 0.6)
  )

  text_x       <- label_x + grid::unit(0.1, "cm")
  text_offset  <- grid::unit(0.18, "cm")

  upper_name_grob <- grid::textGrob(
    upper_name,
    x = text_x, y = upper_y + text_offset, hjust = 0, vjust = 0.5,
    gp = grid::gpar(col = up_col, fontsize = 10, fontface = "bold")
  )
  upper_side_grob <- grid::textGrob(
    "(upper)",
    x = text_x, y = upper_y - text_offset, hjust = 0, vjust = 0.5,
    gp = grid::gpar(col = up_col, fontsize = 8)
  )
  lower_name_grob <- grid::textGrob(
    lower_name,
    x = text_x, y = lower_y + text_offset, hjust = 0, vjust = 0.5,
    gp = grid::gpar(col = lo_col, fontsize = 10, fontface = "bold")
  )
  lower_side_grob <- grid::textGrob(
    "(lower)",
    x = text_x, y = lower_y - text_offset, hjust = 0, vjust = 0.5,
    gp = grid::gpar(col = lo_col, fontsize = 8)
  )

  grid::gTree(
    children = grid::gList(
      upper_tri, lower_tri,
      upper_leader_diag, upper_leader_h,
      lower_leader_diag, lower_leader_h,
      upper_name_grob, upper_side_grob,
      lower_name_grob, lower_side_grob
    ),
    name = "biheat-key-glyph"
  )
}

#' Print method for biheat_plot
#' @param x A `biheat_plot` (gtable).
#' @param ... Ignored.
#' @export
#' @keywords internal
print.biheat_plot <- function(x, ...) {
  grid::grid.newpage()
  grid::grid.draw(x)
  invisible(x)
}

#' Centroid positions for triangle labels
#' @keywords internal
triangle_centroids <- function(tri) {
  split_id <- split(tri[, c("x", "y", "value")], tri$polygon_id)
  cx <- vapply(split_id, function(d) mean(d$x), numeric(1L))
  cy <- vapply(split_id, function(d) mean(d$y), numeric(1L))
  cv <- vapply(split_id, function(d) d$value[1L], numeric(1L))
  data.frame(
    x = unname(cx),
    y = unname(cy),
    label = format(cv, digits = 2),
    stringsAsFactors = FALSE
  )
}
