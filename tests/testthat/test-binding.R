testthat::test_that("b_dose_resp is not equal to drc::drm()", {
  values1 <- drc::drm(density ~ conc, data = DNase, fct = drc::LL.4(fixed = c(1, NA, NA, NA))) %>%
    coefficients() %>%
    unname()

  values2 <- DNase %>%
    b_binding(conc, density) %>%
    b_coefs() %>%
    dplyr::pull(estimate)

  testthat::expect_equal(values1, values2)
})


