test_that("Plotting function.", {
  vdiffr::expect_doppelganger(
    "test enzyme plot",
    fig = {
      DNase %>%
        b_enzyme_rate(conc, density, Run) %>%
        b_plot()
    })
  vdiffr::expect_doppelganger(
    "Coloured, no facet.",
    fig = {
      DNase %>%
        b_enzyme_rate(conc, density, Run) %>%
        b_plot(colour = Run, facet = FALSE)
    })

})
