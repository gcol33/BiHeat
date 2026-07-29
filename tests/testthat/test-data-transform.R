test_that("as_biheat_data preserves dimnames and yields one row per cell", {
  u <- matrix(1:6, 2, 3, dimnames = list(c("r1", "r2"), c("a", "b", "c")))
  l <- matrix(7:12, 2, 3, dimnames = list(c("r1", "r2"), c("a", "b", "c")))

  d <- BiHeat:::as_biheat_data(u, l, "obs", "pred")
  expect_equal(nrow(d), 6)
  expect_setequal(d$row, c("r1", "r2"))
  expect_setequal(d$col, c("a", "b", "c"))
  expect_equal(attr(d, "upper_name"), "obs")
  expect_equal(attr(d, "lower_name"), "pred")

  for (k in seq_len(nrow(d))) {
    expect_equal(d$upper[k], u[d$i[k], d$j[k]])
    expect_equal(d$lower[k], l[d$i[k], d$j[k]])
  }
})

test_that("as_biheat_data invents row/col names when missing", {
  u <- matrix(1:4, 2, 2)
  l <- matrix(5:8, 2, 2)
  d <- BiHeat:::as_biheat_data(u, l)
  expect_setequal(d$row, c("r1", "r2"))
  expect_setequal(d$col, c("c1", "c2"))
})

test_that("as_biheat_data rejects mismatched dimensions", {
  u <- matrix(1:6, 2, 3)
  l <- matrix(1:8, 2, 4)
  expect_error(BiHeat:::as_biheat_data(u, l), "identical dimensions")
})

# One cell centred on (1, 1) with unit extent has corners at
# BL (0.5, 0.5), BR (1.5, 0.5), TL (0.5, 1.5), TR (1.5, 1.5).
one_cell <- function() {
  data.frame(x = 1, y = 1, upper = 10, lower = 20)
}

test_that("build_triangles cuts a down-split cell from top-left to bottom-right", {
  tri <- BiHeat:::build_triangles(one_cell(), split = "down")

  expect_equal(nrow(tri), 6)
  expect_setequal(tri$which, c("upper", "lower"))
  expect_true(all(table(tri$polygon_id) == 3))

  up <- tri[tri$which == "upper", ]
  lo <- tri[tri$which == "lower", ]

  # Upper triangle takes TL, TR, BR: it holds the top-right corner and
  # leaves the bottom-left one to the lower triangle.
  expect_true(any(up$x == 1.5 & up$y == 1.5))
  expect_false(any(up$x == 0.5 & up$y == 0.5))
  expect_true(any(lo$x == 0.5 & lo$y == 0.5))
  expect_false(any(lo$x == 1.5 & lo$y == 1.5))

  expect_equal(unique(up$value), 10)
  expect_equal(unique(lo$value), 20)
})

test_that("build_triangles cuts an up-split cell from bottom-left to top-right", {
  tri <- BiHeat:::build_triangles(one_cell(), split = "up")

  up <- tri[tri$which == "upper", ]
  lo <- tri[tri$which == "lower", ]

  # Upper triangle takes BL, TL, TR: it holds the top-left corner and
  # leaves the bottom-right one to the lower triangle.
  expect_true(any(up$x == 0.5 & up$y == 1.5))
  expect_false(any(up$x == 1.5 & up$y == 0.5))
  expect_true(any(lo$x == 1.5 & lo$y == 0.5))
  expect_false(any(lo$x == 0.5 & lo$y == 1.5))
})

test_that("build_triangles produces two triangles per cell", {
  u <- matrix(1:4, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  l <- matrix(5:8, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  d <- BiHeat:::as_biheat_data(u, l)
  d$x <- d$j
  d$y <- -d$i
  tri <- BiHeat:::build_triangles(d, split = "down")

  # 4 cells x 2 triangles x 3 vertices = 24 rows
  expect_equal(nrow(tri), 24)
  expect_true(all(table(tri$polygon_id) == 3))
  expect_equal(sort(unique(tri$.row)), 1:4)
})

test_that("build_triangles honours inset and per-cell width / height", {
  tri <- BiHeat:::build_triangles(one_cell(), split = "down", inset = 0.1)
  expect_setequal(round(tri$x, 6), c(0.6, 1.4))
  expect_setequal(round(tri$y, 6), c(0.6, 1.4))

  wide <- one_cell()
  wide$width <- 4
  wide$height <- 2
  tri_wide <- BiHeat:::build_triangles(wide, split = "down")
  expect_setequal(tri_wide$x, c(-1, 3))
  expect_setequal(tri_wide$y, c(0, 2))
})

test_that("build_triangles rejects an out-of-range inset", {
  expect_error(BiHeat:::build_triangles(one_cell(), inset = 0.5), "\\[0, 0.5\\)")
  expect_error(BiHeat:::build_triangles(one_cell(), inset = -1), "\\[0, 0.5\\)")
})

test_that("build_triangles returns an empty frame for empty input", {
  empty <- data.frame(x = numeric(0), y = numeric(0),
                      upper = numeric(0), lower = numeric(0))
  tri <- BiHeat:::build_triangles(empty)
  expect_equal(nrow(tri), 0)
  expect_named(tri, c("x", "y", "polygon_id", "which", "value", ".row"))
})

test_that("map_colour rescales, clamps, and marks NA", {
  pal <- scales::gradient_n_pal(c("white", "red"))
  out <- BiHeat:::map_colour(c(0, 0.5, 1), c(0, 1), pal, "grey90")
  expect_equal(out[1], pal(0))
  expect_equal(out[3], pal(1))

  # Values outside the range clamp to the palette ends rather than dropping out.
  clamped <- BiHeat:::map_colour(c(-5, 5), c(0, 1), pal, "grey90")
  expect_equal(clamped, c(pal(0), pal(1)))

  expect_equal(BiHeat:::map_colour(NA_real_, c(0, 1), pal, "grey90"), "grey90")
  expect_equal(BiHeat:::map_colour(c(NA, NA), c(0, 1), pal, "grey80"),
               c("grey80", "grey80"))
})

test_that("map_colour sends a degenerate range to the palette midpoint", {
  pal <- scales::gradient_n_pal(c("white", "red"))
  expect_equal(BiHeat:::map_colour(c(3, 3), c(3, 3), pal, "grey90"),
               c(pal(0.5), pal(0.5)))
})
