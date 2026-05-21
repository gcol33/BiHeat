test_that("biheat() returns a biheat_plot for matched matrices", {
  set.seed(1)
  u <- matrix(runif(12), 3, 4)
  l <- matrix(runif(12), 3, 4)
  p <- biheat(u, l)
  expect_s3_class(p, "biheat_plot")
  expect_s3_class(p, "gtable")
})

test_that("biheat() with show_key = FALSE returns a plain ggplot", {
  set.seed(1)
  u <- matrix(runif(12), 3, 4)
  l <- matrix(runif(12), 3, 4)
  p <- biheat(u, l, show_key = FALSE)
  expect_s3_class(p, "ggplot")
  expect_false(inherits(p, "biheat_plot"))
})

test_that("biheat() captures arg-symbol names for upper / lower", {
  obs <- matrix(1:4, 2, 2)
  pre <- matrix(5:8, 2, 2)
  p <- biheat(obs, pre)
  spec <- attr(p, "clutch_spec")
  expect_equal(spec$upper_name, "obs")
  expect_equal(spec$lower_name, "pre")
})

test_that("biheat(a, b, ...) equals breed(a, b) |> incubate(...) |> plot()", {
  set.seed(2)
  u <- matrix(runif(20), 4, 5)
  l <- matrix(runif(20), 4, 5)

  p1 <- biheat(u, l, scale = "shared", split = "up", show_key = FALSE)
  p2 <- plot(incubate(breed(u, l, upper_name = "u", lower_name = "l"),
                      scale = "shared", split = "up", show_key = FALSE))
  expect_equal(attr(p1, "clutch_spec")$scale, attr(p2, "clutch_spec")$scale)
  expect_equal(attr(p1, "clutch_spec")$split, attr(p2, "clutch_spec")$split)
  expect_equal(attr(p1, "clutch_spec")$data, attr(p2, "clutch_spec")$data)
})

test_that("biheat() accepts a clutch directly", {
  u <- matrix(1:6, 2, 3); l <- matrix(7:12, 2, 3)
  cl <- breed(u, l, "obs", "pred")
  p <- biheat(cl)
  expect_s3_class(p, "biheat_plot")
})

test_that("biheat(clutch, lower) errors", {
  u <- matrix(1:6, 2, 3); l <- matrix(7:12, 2, 3)
  cl <- breed(u, l)
  expect_error(biheat(cl, l), "either a `clutch` or two matrices")
})

test_that("biheat() handles NA via na_colour scale", {
  u <- matrix(c(1, NA, 3, 4), 2, 2)
  l <- matrix(c(1, 2, 3, 4), 2, 2)
  p <- biheat(u, l, na_colour = "grey80", show_key = FALSE)
  # First scale handles upper triangle; na.value should be the user-set value.
  expect_equal(p$scales$scales[[1]]$na.value, "grey80")
})

test_that("biheat() honours row_order / col_order", {
  u <- matrix(1:4, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  l <- u
  p <- biheat(u, l, row_order = c("r2", "r1"), col_order = c("b", "a"))
  expect_s3_class(p, "biheat_plot")
})

test_that("biheat() rejects bad orderings", {
  u <- matrix(1:4, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  l <- u
  expect_error(biheat(u, l, row_order = c("x", "y")), "permutation")
  expect_error(biheat(u, l, col_order = c("x", "y")), "permutation")
})
