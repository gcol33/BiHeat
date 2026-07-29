test_that("nice_axis picks round breaks inside the data range", {
  ax <- BiHeat:::nice_axis(c(0.02, 0.97))
  expect_true(all(ax$breaks >= 0))
  expect_true(all(ax$breaks <= 1))
  expect_true(length(ax$breaks) >= 2)
  expect_true(ax$limits[1] <= 0.02)
  expect_true(ax$limits[2] >= 0.97)
})

test_that("nice_axis pads a degenerate range", {
  ax <- BiHeat:::nice_axis(c(5, 5))
  expect_equal(ax$breaks, 5)
  expect_true(ax$limits[1] < 5 && ax$limits[2] > 5)

  zero <- BiHeat:::nice_axis(c(0, 0))
  expect_equal(zero$limits, c(-1, 1))
})

test_that("nice_axis passes non-finite ranges through", {
  ax <- BiHeat:::nice_axis(c(NA_real_, NA_real_))
  expect_true(all(is.na(ax$limits)))
  expect_s3_class(ax$breaks, "waiver")
})

test_that("triangle_centroids sits one label at the centre of each triangle", {
  d <- data.frame(x = 1, y = 1, upper = 10, lower = 20)
  tri <- BiHeat:::build_triangles(d, split = "down", inset = 0)
  cent <- BiHeat:::triangle_centroids(tri)

  expect_equal(nrow(cent), 2)
  expect_setequal(trimws(cent$label), c("10", "20"))
  # Both centroids stay inside the cell footprint.
  expect_true(all(cent$x > 0.5 & cent$x < 1.5))
  expect_true(all(cent$y > 0.5 & cent$y < 1.5))
})

test_that("rows read top to bottom on an upward y axis", {
  u <- matrix(1:4, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  p <- plot(breed(u, u), show_key = FALSE)

  y_scale <- p$scales$get_scales("y")
  expect_equal(y_scale$labels, c("r1", "r2"))
  expect_equal(y_scale$breaks, c(-1, -2))
})

test_that("the upper triangle is drawn above the diagonal", {
  u <- matrix(1, 1, 1, dimnames = list("r1", "a"))
  l <- matrix(2, 1, 1, dimnames = list("r1", "a"))
  p <- plot(breed(u, l), show_key = FALSE, split = "down")

  built <- ggplot2::ggplot_build(p)
  upper <- built$data[[1]]
  # Cell centre is (1, -1); the down-split upper triangle keeps the
  # top-right corner and drops the bottom-left one.
  expect_true(any(upper$x > 1 & upper$y > -1))
  expect_false(any(upper$x < 1 & upper$y < -1))
})

test_that("show_values prints one label per triangle", {
  u <- matrix(1:4, 2, 2)
  l <- matrix(5:8, 2, 2)
  p <- plot(breed(u, l), show_values = TRUE, show_key = FALSE)
  built <- ggplot2::ggplot_build(p)
  text_layer <- built$data[[length(built$data)]]
  expect_equal(nrow(text_layer), 8)
})

test_that("shared scale puts both triangles on one range", {
  u <- matrix(c(0, 1, 2, 3), 2, 2)
  l <- matrix(c(10, 11, 12, 13), 2, 2)
  p <- plot(breed(u, l), scale = "shared", show_key = FALSE)
  spec <- attr(p, "clutch_spec")
  expect_equal(spec$upper_range, spec$lower_range)
  expect_equal(spec$upper_range, c(0, 13))
})

test_that("legend_position = 'none' skips the key glyph", {
  u <- matrix(1:4, 2, 2)
  p <- plot(breed(u, u), legend_position = "none")
  expect_false(inherits(p, "biheat_plot"))
})

test_that("the key glyph is injected into the guide box", {
  u <- matrix(1:4, 2, 2)
  p <- plot(breed(u, u))
  expect_s3_class(p, "biheat_plot")

  guide_idx <- which(p$layout$name %in% c("guide-box-right", "guide-box"))
  expect_true(length(guide_idx) > 0)
  guide_box <- p$grobs[[guide_idx[1]]]
  expect_true("biheat-key" %in% guide_box$layout$name)
})

test_that("print.biheat_plot draws and returns invisibly", {
  u <- matrix(1:4, 2, 2)
  p <- plot(breed(u, u))
  pdf(NULL)
  on.exit(dev.off(), add = TRUE)
  expect_invisible(print(p))
})

test_that("theme_biheat strips the panel furniture", {
  th <- theme_biheat()
  expect_s3_class(th, "theme")
  expect_s3_class(th$panel.grid, "element_blank")
  expect_s3_class(th$axis.ticks, "element_blank")
  expect_equal(th$legend.position, "right")
})

test_that("print.biheat_data previews the tidy table", {
  u <- matrix(1:9, 3, 3)
  l <- matrix(2:10, 3, 3)
  d <- comes_out(breed(u, l))
  out <- capture.output(print(d, n = 2))
  expect_true(any(grepl("<biheat_data> 9 cells", out)))
  expect_true(any(grepl("7 more rows", out)))
})
