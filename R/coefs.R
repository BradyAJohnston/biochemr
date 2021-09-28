#' Extract Model Parameters to Columns
#'
#' @param data Tibble containing a `coefs` column resulting from a model fit.
#'
#' @return tibble containing grouped variables and extracted parameters.
#' @importFrom rlang .data
#' @export
#'
#' @examples
#'
#' # Fitting MM models to the enzymatic data, pull out the relevant information.
#' Puromycin %>%
#'  b_enzyme_rate(conc, rate, state) %>%
#'  b_coefs()
#'
b_coefs <- function(data) {
  results <- data %>%
    # get only rows for which the model fit succeeded
    dplyr::filter(!is.na(.data$drmod)) %>%
    # unnest the coefficients nested lists
    tidyr::unnest(.data$coefs) %>%
    # select quietly, ignore the message saying grouping column also selected
    purrr::quietly(dplyr::select)(
      !tidyselect::vars_select_helpers$where(is.list)
      )

    # get the result of purrr::quietly
    results[[1]]
}
