test_that("palettes() constructs a palettes pair", {
  pp <- palettes(c("white", "red"), c("white", "blue"))
  expect_s3_class(pp, "palettes")
  expect_equal(pp$upper, c("white", "red"))
  expect_equal(pp$lower, c("white", "blue"))
})

test_that("palettes() validates colour vector lengths", {
  expect_error(palettes(upper = "red"),  "length >= 2")
  expect_error(palettes(lower = "blue"), "length >= 2")
})

test_that("print.palettes shows both gradients", {
  pp <- palettes(c("white", "red"), c("white", "blue"))
  out <- capture.output(print(pp))
  expect_true(any(grepl("upper", out)))
  expect_true(any(grepl("lower", out)))
})
