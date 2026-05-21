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

test_that("build_triangles produces two triangles per cell with correct corners", {
  u <- matrix(1:4, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  l <- matrix(5:8, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  d <- BiHeat:::as_biheat_data(u, l)
  tri <- BiHeat:::build_triangles(d, split = "down")

  # 4 cells x 2 triangles x 3 vertices = 24 rows
  expect_equal(nrow(tri), 24)
  expect_setequal(tri$which, c("upper", "lower"))

  per_poly <- table(tri$polygon_id)
  expect_true(all(per_poly == 3))

  # cell (i=1, j=1), upper triangle (down-split, top-right):
  # vertices TL=(0.5, 0.5), TR=(1.5, 0.5), BR=(1.5, 1.5)
  cell <- tri[tri$polygon_id == "u_1", ]
  expect_setequal(cell$x, c(0.5, 1.5))
  expect_setequal(cell$y, c(0.5, 1.5))
})

test_that("build_triangles up-split uses the opposite diagonal", {
  u <- matrix(1, 1, 1); l <- matrix(2, 1, 1)
  d <- BiHeat:::as_biheat_data(u, l)
  tri_up <- BiHeat:::build_triangles(d, split = "up")

  up <- tri_up[tri_up$which == "upper", ]
  expect_equal(nrow(up), 3)
  expect_false(any(up$x == 1.5 & up$y == 1.5))    # no BR in upper triangle
})
