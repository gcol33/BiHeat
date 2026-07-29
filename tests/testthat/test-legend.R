test_that("bi_legend() returns a drawable grob carrying its spec", {
  g <- bi_legend("obs", "pred")
  expect_s3_class(g, "bi_legend")
  expect_s3_class(g, "gTree")

  spec <- attr(g, "spec")
  expect_equal(spec$upper_name, "obs")
  expect_equal(spec$lower_name, "pred")
  expect_equal(spec$split, "down")

  pdf(NULL)
  on.exit(dev.off(), add = TRUE)
  expect_silent(grid::grid.draw(g))
})

test_that("bi_legend() carries both palettes and both ranges", {
  g <- bi_legend("a", "b",
                 upper_palette = c("white", "darkred"),
                 lower_palette = c("white", "navy"),
                 upper_range = c(0, 10),
                 lower_range = c(-1, 1),
                 split = "up")
  spec <- attr(g, "spec")
  expect_equal(spec$upper_palette, c("white", "darkred"))
  expect_equal(spec$lower_palette, c("white", "navy"))
  expect_equal(spec$upper_range, c(0, 10))
  expect_equal(spec$lower_range, c(-1, 1))
  expect_equal(spec$split, "up")
})

test_that("bi_legend() rejects malformed ranges", {
  expect_error(bi_legend(upper_range = 1), "length 2")
  expect_error(bi_legend(lower_range = c("a", "b")), "length 2")
})

test_that("print.bi_legend draws and returns invisibly", {
  g <- bi_legend()
  pdf(NULL)
  on.exit(dev.off(), add = TRUE)
  expect_invisible(print(g))
})

test_that("key_glyph_grob builds one square plus leaders and labels", {
  key <- BiHeat:::key_glyph_grob("obs", "pred")
  expect_s3_class(key, "gTree")
  expect_equal(length(key$children), 10)

  labels <- vapply(key$children, function(g) {
    if (inherits(g, "text")) as.character(g$label) else NA_character_
  }, character(1))
  expect_true(all(c("obs", "pred", "(upper)", "(lower)") %in% labels))
})

test_that("key_glyph_grob flips its triangles with split", {
  down <- BiHeat:::key_glyph_grob(split = "down")
  up   <- BiHeat:::key_glyph_grob(split = "up")
  expect_false(identical(as.numeric(down$children[[1]]$x),
                         as.numeric(up$children[[1]]$x)))
})
