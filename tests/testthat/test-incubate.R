test_that("incubate() merges config additively", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l) |> incubate(scale = "shared") |> incubate(split = "up")
  expect_equal(cl$config$scale, "shared")
  expect_equal(cl$config$split, "up")
})

test_that("incubate() leaves unset options absent (not NA)", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l) |> incubate(scale = "shared")
  expect_false("split" %in% names(cl$config))
})

test_that("incubate() accepts a palettes() object", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  pp <- palettes(c("white", "darkred"), c("white", "navy"))
  cl <- breed(u, l) |> incubate(palettes = pp)
  expect_identical(cl$config$palettes, pp)
})

test_that("incubate() promotes a bare colour vector into palettes()", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l) |> incubate(palettes = c("white", "darkred"),
                                lower_palette = c("white", "navy"))
  expect_s3_class(cl$config$palettes, "palettes")
  expect_equal(cl$config$palettes$upper, c("white", "darkred"))
  expect_equal(cl$config$palettes$lower, c("white", "navy"))
})

test_that("incubate() can override upper_name / lower_name", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l, "a", "b") |> incubate(upper_name = "X", lower_name = "Y")
  expect_equal(cl$upper_name, "X")
  expect_equal(cl$lower_name, "Y")
})

test_that("incubate() rejects non-clutch input", {
  expect_error(incubate(list()), "expects a clutch")
})
