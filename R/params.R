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
#'  b_coefs()
#'
b_coefs <- function(data) {
  data %>%
    # get only rows for which the model fit succeeded
    dplyr::filter(!is.na(drmod)) %>%
    # unnest the coefficients nested lists
    tidyr::unnest(coefs) %>%
    # select quietly, ignore the message saying grouping column also selected
    purrr::quietly(dplyr::select)(!where(is.list)) %>%
    # get the result of purrr::quietly
    .[[1]] #%>%
    # pivot the values wider for a more human-readable table
    # tidyr::pivot_wider(names_from = parameter, values_from = value)
}
