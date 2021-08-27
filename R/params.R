#' Extract Model Parameters to Columns
#'
#' @param data Tibble containing a `coefs` column resulting from a model fit.
#'
#' @return tibble containing grouped variables and extracted parameters.
#' @export
#'
#' @example
#'
#' # Fitting MM models to the enzymatic data, pull out the relevant information.
#' Puromycin %>%
#'  b_enzyme_rate(conc, rate, state) %>%
#'  b_params()
#'
b_params <- function(data) {
  data %>%
    tidyr::unnest(coefs) %>%
    dplyr::mutate(parameter = stringr::str_remove_all(parameter, ":\\(Intercept\\)")) %>%
    dplyr::select(parameter, value) %>%
    tidyr::pivot_wider(names_from = parameter, values_from = value)

}
