skip_if_not_installed("vdiffr")

fixture <- function() {
  set.seed(1)
  species <- LETTERS[1:4]
  sites   <- letters[1:5]
  observed  <- matrix(runif(20), 4, 5, dimnames = list(species, sites))
  predicted <- observed + matrix(rnorm(20, sd = 0.1), 4, 5,
                                 dimnames = list(species, sites))
  list(observed = observed, predicted = predicted)
}

test_that("default heatmap renders", {
  f <- fixture()
  p <- biheat(f$observed, f$predicted)
  vdiffr::expect_doppelganger("default", function() grid::grid.draw(p))
})

test_that("up split on a shared scale renders", {
  f <- fixture()
  p <- biheat(f$observed, f$predicted, split = "up", scale = "shared")
  vdiffr::expect_doppelganger("up-split-shared", function() grid::grid.draw(p))
})

test_that("values and custom palettes render", {
  f <- fixture()
  p <- biheat(f$observed, f$predicted,
              palettes = palettes(c("white", "darkorange", "darkred"),
                                  c("white", "steelblue", "navy")),
              show_values = TRUE, show_key = FALSE)
  vdiffr::expect_doppelganger("values-custom-palettes", p)
})

test_that("standalone legend renders", {
  g <- bi_legend("observed", "predicted", upper_range = c(0, 1),
                 lower_range = c(-1, 1))
  vdiffr::expect_doppelganger("bi-legend", function() grid::grid.draw(g))
})

test_that("geom_biheat layer renders", {
  cells <- expand.grid(site = letters[1:5], species = LETTERS[1:4])
  set.seed(2)
  cells$observed  <- runif(20)
  cells$predicted <- runif(20)

  p <- ggplot2::ggplot(cells, ggplot2::aes(site, species,
                                           upper = observed, lower = predicted)) +
    geom_biheat() +
    theme_biheat()
  vdiffr::expect_doppelganger("geom-biheat", p)
})
