testthat::test_that("b_enyme_rate is not equal to drc::drm()", {
  values1 <- drc::drm(rate ~ conc,
                      data = Puromycin,
                      curveid = state,
                      fct = drc::MM.2(names = c("Vmax", "Km"))) %>%
    coefficients() %>%
    unname() %>%
    sort() %>%
    round(4)

  values2 <- Puromycin %>%
    b_enzyme_rate(conc, rate, state) %>%
    b_coefs() %>%
    dplyr::pull(estimate) %>%
    sort() %>%
    round(4)

  testthat::expect_equal(values1, values2)
})
