test_that("breed() builds a clutch with comparison meta", {
  u <- matrix(1:9, 3, 3, dimnames = list(LETTERS[1:3], letters[1:3]))
  l <- matrix(2:10, 3, 3, dimnames = list(LETTERS[1:3], letters[1:3]))
  cl <- breed(u, l)
  expect_s3_class(cl, "clutch")
  expect_equal(dim(cl$upper), c(3, 3))
  expect_equal(dim(cl$lower), c(3, 3))
  expect_equal(cl$meta$pearson, 1)         # perfect linear relationship
  expect_equal(cl$meta$rmse, 1)            # constant offset of 1
  expect_equal(cl$meta$mae,  1)
})

test_that("breed() captures arg-symbol names by default", {
  observed  <- matrix(1:4, 2, 2)
  predicted <- matrix(5:8, 2, 2)
  cl <- breed(observed, predicted)
  expect_equal(cl$upper_name, "observed")
  expect_equal(cl$lower_name, "predicted")
})

test_that("breed() intersects on overlapping dimnames", {
  u <- matrix(1:6, 2, 3, dimnames = list(c("r1", "r2"), c("a", "b", "c")))
  l <- matrix(11:18, 2, 4, dimnames = list(c("r1", "r2"), c("b", "c", "d", "e")))
  cl <- breed(u, l)
  expect_equal(cl$align_report$mode, "intersect")
  expect_equal(cl$align_report$rows_kept, 2)
  expect_equal(cl$align_report$cols_kept, 2)   # only b, c overlap
  expect_setequal(colnames(cl$upper), c("b", "c"))
  expect_setequal(colnames(cl$lower), c("b", "c"))
})

test_that("breed() errors on disjoint dimnames", {
  u <- matrix(1:4, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  l <- matrix(5:8, 2, 2, dimnames = list(c("r1", "r2"), c("x", "y")))
  expect_error(breed(u, l), "No overlapping column names")
})

test_that("breed() falls back to by_position when neither has names", {
  u <- matrix(1:6, 2, 3)
  l <- matrix(7:12, 2, 3)
  cl <- breed(u, l)
  expect_equal(cl$align_report$mode, "by_position")
})

test_that("breed(align='by_position') requires identical shape", {
  u <- matrix(1:6, 2, 3, dimnames = list(c("r1", "r2"), c("a", "b", "c")))
  l <- matrix(1:4, 2, 2, dimnames = list(c("r1", "r2"), c("a", "b")))
  expect_error(breed(u, l, align = "by_position"), "different dimensions")
})

test_that("clutch has an empty config until incubated", {
  u <- matrix(1:4, 2, 2); l <- matrix(5:8, 2, 2)
  cl <- breed(u, l)
  expect_equal(length(cl$config), 0)
})

test_that("print.clutch shows pearson/rmse/mae when computable", {
  u <- matrix(1:9, 3, 3); l <- matrix(2:10, 3, 3)
  cl <- breed(u, l)
  out <- capture.output(print(cl))
  expect_true(any(grepl("pearson", out)))
  expect_true(any(grepl("rmse", out)))
})

test_that("plot(clutch) returns a biheat_plot", {
  u <- matrix(1:6, 2, 3); l <- matrix(7:12, 2, 3)
  p <- plot(breed(u, l))
  expect_s3_class(p, "biheat_plot")
})

test_that("plot.clutch(...) applies trailing config", {
  u <- matrix(1:6, 2, 3); l <- matrix(7:12, 2, 3)
  p <- plot(breed(u, l), scale = "shared", split = "up")
  spec <- attr(p, "clutch_spec")
  expect_equal(spec$scale, "shared")
  expect_equal(spec$split, "up")
})
