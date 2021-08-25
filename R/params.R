#' Extract Model Parameters to Columns
#'
#' @param data Tibble containing a `coefs` column resulting from a model fit.
#'
#' @return tibble containing grouped variables and extracted parameters.
#' @export
#'
#' @examples
#'
#'
b_params <- function(data) {
  data %>%
    unnest(coefs) %>%
    mutate(parameter = str_remove_all(parameter, ":\\(Intercept\\)")) %>%
    select(parameter, value) %>%
    pivot_wider(names_from = parameter, values_from = value)
}
