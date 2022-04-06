test_that("Plotting function.", {
  vdiffr::expect_doppelganger(
    "test enzyme plot",
    fig = {
      DNase %>%
        bio_enzyme_rate(conc, density, group = Run) %>%
        bio_plot()
    }
  )
  vdiffr::expect_doppelganger(
    "Coloured, no facet.",
    fig = {
      DNase %>%
        bio_enzyme_rate(conc, density, group = Run) %>%
        bio_plot(colour = Run, facet = FALSE)
    }
  )
})
