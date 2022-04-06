testthat::test_that("bio_dose_resp is not equal to drc::drm()", {
  values1 <- drc::drm(density ~ conc, data = DNase, fct = drc::LL.4(fixed = c(1, NA, NA, NA))) %>%
    coefficients() %>%
    unname()

  values2 <- DNase %>%
    bio_binding(conc, density) %>%
    bio_coefs() %>%
    dplyr::pull(estimate)

  testthat::expect_equal(values1, values2)
})
