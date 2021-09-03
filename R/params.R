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
    # unnest the coefficients nested lists
    tidyr::unnest(coefs) %>%

    # remove the "intercept" etc that was included from the (drc) package
    dplyr::mutate(parameter = stringr::str_remove_all(parameter, ":\\(Intercept\\)")) %>%

    # select quietly, ignore the message saying grouping column also selected
    purrr::quietly(dplyr::select)(parameter, value) %>%

    # get the result of purrr::quietly
    .[[1]] %>%

    # pivot the values wider for a more human-readable table
    tidyr::pivot_wider(names_from = parameter, values_from = value)

}
