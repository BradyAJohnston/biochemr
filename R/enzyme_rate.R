#' Fit Michaelis Menton Curve
#'
#' @param conc column with concentration data.
#' @param rate Column with reaction rate data.
#' @param ... Columns with grouping data.
#' @param model Model to fit defaults to `drc::MM.2()`
#'
#' @return `tibble` with nested list columns of data, model, predictions,
#'  residuals and coefficients.
#' @export
#'
#' @examples
#' df <- Puromycin %>%
#'   b_dose_resp(conc, rate, state, model = drc::MM.2(names = c("Vmax", "Km")))
b_enzyme_rate <-
  function(conc,
           rate,
           ...,
           model = drc::MM.2(names = c("Vmax", "Km"))) {
    b_dose_resp(conc, rate, ..., model = model)
}
