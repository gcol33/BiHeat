test_that("switch_sides() swaps upper and lower on a clutch", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l, "obs", "pred")
  s <- switch_sides(cl)
  expect_equal(s$upper, l)
  expect_equal(s$lower, u)
  expect_equal(s$upper_name, "pred")
  expect_equal(s$lower_name, "obs")
  expect_equal(s$data$upper, cl$data$lower)
})

test_that("switch_sides() rejects non-clutch input", {
  expect_error(switch_sides(list()), "expects a clutch")
})

test_that("straighten() toggles split", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l)
  expect_equal(straighten(cl)$config$split, "up")
  expect_equal(straighten(straighten(cl))$config$split, "down")
})

test_that("bothways() toggles scale (and accepts explicit value)", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l)
  expect_equal(bothways(cl)$config$scale, "shared")
  expect_equal(bothways(bothways(cl))$config$scale, "separate")
  expect_equal(bothways(cl, "shared")$config$scale, "shared")
})

test_that("comes_out() returns the tidy data from clutch or ggplot", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l)
  d1 <- comes_out(cl)
  expect_s3_class(d1, "biheat_data")
  expect_equal(nrow(d1), 4)

  p <- biheat(u, l)
  d2 <- comes_out(p)
  expect_s3_class(d2, "biheat_data")
})

test_that("comes_out() rejects unrelated input", {
  expect_error(comes_out(list()), "expects a clutch or a BiHeat ggplot")
})

test_that("verbs compose under pipe", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  p <- breed(u, l) |> switch_sides() |> bothways() |> straighten() |> plot()
  expect_s3_class(p, "biheat_plot")
  spec <- attr(p, "clutch_spec")
  expect_equal(spec$scale, "shared")
  expect_equal(spec$split, "up")
})
