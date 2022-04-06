test_that("Plotting function.", {
  vdiffr::expect_doppelganger(
    "test enzyme plot",
    fig = {
      DNase %>%
        dplyr::group_by(Run) %>%
        bio_enzyme_rate(conc, density) %>%
        bio_plot()
    }
  )
  vdiffr::expect_doppelganger(
    "Coloured, no facet.",
    fig = {
      DNase %>%
        dplyr::group_by(Run) %>%
        bio_enzyme_rate(conc, density) %>%
        bio_plot(colour = Run, facet = FALSE)
    }
  )
})
