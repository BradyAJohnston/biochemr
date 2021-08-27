#' Fit Michaelis Menton Curve
#'
#' @param conc column with concentration data.
#' @param rate Column with reaction rate data.
#' @param ... Columns with grouping data.
#' @param model Model to fit defaults to `drc::MM.2()`
#' @param data Data frame with columns for concentration, reaction rate and
#'   optionally grouping information.
#'
#' @return `tibble` with nested list columns of data, model, predictions,
#'  residuals and coefficients.
#' @export
#'
#' @example
#' # Fitting MM curves to the enzymatic data inside of datasets::Puromycin
#' Puromycin %>%
#'  b_enzyme_rate(conc, rate, state)
#'
b_enzyme_rate <-
  function(data,
           conc,
           rate,
           ...,
           model = drc::MM.2(names = c("Vmax", "Km"))) {
    b_dose_resp(data = data,
                dose = conc,
                response = rate,
                ... = ...,
                model = model)
  }
