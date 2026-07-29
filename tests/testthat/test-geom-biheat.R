cells <- function() {
  grid <- expand.grid(site = letters[1:3], species = LETTERS[1:2],
                      stringsAsFactors = TRUE)
  grid$observed  <- seq(0, 1, length.out = 6)
  grid$predicted <- seq(1, 0, length.out = 6)
  grid
}

layer_polygons <- function(p) {
  grob <- ggplot2::layer_grob(p)[[1]]
  expect_s3_class(grob, "polygon")
  grob
}

test_that("geom_biheat() builds a layer that draws two triangles per cell", {
  p <- ggplot2::ggplot(cells(), ggplot2::aes(site, species,
                                             upper = observed, lower = predicted)) +
    geom_biheat()

  expect_s3_class(p$layers[[1]]$geom, "GeomBiheat")

  built <- ggplot2::ggplot_build(p)
  expect_equal(nrow(built$data[[1]]), 6)

  grob <- layer_polygons(p)
  # 6 cells x 2 triangles x 3 vertices
  expect_equal(length(grob$x), 36)
  expect_equal(length(unique(grob$id)), 12)
  expect_equal(length(grob$gp$fill), 12)
})

test_that("geom_biheat() maps each triangle through its own palette", {
  p <- ggplot2::ggplot(cells(), ggplot2::aes(site, species,
                                             upper = observed, lower = predicted)) +
    geom_biheat(palettes = palettes(c("white", "red"), c("white", "blue")),
                cell_inset = 0)

  d <- ggplot2::ggplot_build(p)$data[[1]]
  fills <- layer_polygons(p)$gp$fill
  n <- nrow(d)
  upper_fills <- fills[seq_len(n)]
  lower_fills <- fills[n + seq_len(n)]

  # Both sides run white -> saturated across their own value range.
  expect_equal(toupper(upper_fills[which.min(d$upper)]), "#FFFFFF")
  expect_equal(toupper(upper_fills[which.max(d$upper)]), "#FF0000")
  expect_equal(toupper(lower_fills[which.min(d$lower)]), "#FFFFFF")
  expect_equal(toupper(lower_fills[which.max(d$lower)]), "#0000FF")
})

test_that("geom_biheat() honours explicit value ranges", {
  d <- cells()
  p_auto <- ggplot2::ggplot(d, ggplot2::aes(site, species,
                                            upper = observed, lower = predicted)) +
    geom_biheat()
  p_wide <- ggplot2::ggplot(d, ggplot2::aes(site, species,
                                            upper = observed, lower = predicted)) +
    geom_biheat(upper_range = c(-1, 2))

  auto <- layer_polygons(p_auto)$gp$fill[1:6]
  wide <- layer_polygons(p_wide)$gp$fill[1:6]
  expect_false(identical(auto, wide))
})

test_that("geom_biheat() paints NA cells with na_colour", {
  d <- cells()
  d$observed[1] <- NA
  p <- ggplot2::ggplot(d, ggplot2::aes(site, species,
                                       upper = observed, lower = predicted)) +
    geom_biheat(na_colour = "grey80")

  built <- ggplot2::ggplot_build(p)$data[[1]]
  fills <- layer_polygons(p)$gp$fill

  # The cell survives with its lower triangle intact; only the upper one
  # falls back to na_colour.
  na_hex <- grDevices::rgb(t(grDevices::col2rgb("grey80")), maxColorValue = 255)
  gone <- which(is.na(built$upper))

  expect_equal(nrow(built), 6)
  expect_equal(substr(fills[gone], 1, 7), na_hex)
  expect_false(substr(fills[nrow(built) + gone], 1, 7) == na_hex)
})

test_that("geom_biheat() promotes a bare colour vector into palettes()", {
  p <- ggplot2::ggplot(cells(), ggplot2::aes(site, species,
                                             upper = observed, lower = predicted)) +
    geom_biheat(palettes = c("white", "black"), lower_palette = c("white", "black"))

  d <- ggplot2::ggplot_build(p)$data[[1]]
  fills <- layer_polygons(p)$gp$fill
  expect_equal(toupper(fills[which.max(d$upper)]), "#000000")
  expect_equal(toupper(fills[nrow(d) + which.max(d$lower)]), "#000000")
})

test_that("geom_biheat() rejects malformed ranges", {
  expect_error(geom_biheat(upper_range = 1), "length 2")
  expect_error(geom_biheat(lower_range = c(NA, 1)), "length 2")
})

test_that("geom_biheat() splits the other way on split = 'up'", {
  d <- cells()
  down <- layer_polygons(
    ggplot2::ggplot(d, ggplot2::aes(site, species, upper = observed, lower = predicted)) +
      geom_biheat(split = "down")
  )
  up <- layer_polygons(
    ggplot2::ggplot(d, ggplot2::aes(site, species, upper = observed, lower = predicted)) +
      geom_biheat(split = "up")
  )
  expect_false(isTRUE(all.equal(as.numeric(down$x), as.numeric(up$x))))
  expect_equal(down$gp$fill, up$gp$fill)
})

test_that("geom_biheat() leaves the fill scale free for other layers", {
  d <- cells()
  d$flag <- d$observed > 0.5
  p <- ggplot2::ggplot(d, ggplot2::aes(site, species,
                                       upper = observed, lower = predicted)) +
    geom_biheat() +
    ggplot2::geom_point(ggplot2::aes(fill = flag), shape = 21)

  built <- ggplot2::ggplot_build(p)
  expect_true("fill" %in% names(built$data[[2]]))
  expect_s3_class(ggplot2::ggplot_gtable(built), "gtable")
})

test_that("geom_biheat() accepts fixed cell extents", {
  p <- ggplot2::ggplot(cells(), ggplot2::aes(site, species,
                                             upper = observed, lower = predicted)) +
    geom_biheat(width = 0.5, height = 0.5, cell_inset = 0)

  built <- ggplot2::ggplot_build(p)
  expect_equal(unique(built$data[[1]]$width), 0.5)
  expect_equal(unique(built$data[[1]]$xmax - built$data[[1]]$xmin), 0.5)
})
