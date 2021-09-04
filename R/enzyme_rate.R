#' Fit a Michaelis-Menton Curve to Enzymatic Data
#'
#' This function fits a Michaelis-Menton model to the some dose-response data
#' for enzymatic reactions. By default the minimum rate is locked to 0, if you
#' wish to let the function find the minimum (if enzyme rate is > 0 at
#' concentration 0) then supply the model `drc::MM.3(names = c("min", "Vmax",
#' "km"))`.
#'
#' @param data Data frame with columns for concentration, reaction rate and
#'   optionally grouping information.
#' @param conc Column containing the concentration data.
#' @param rate Column containing the enzyme rate data.
#' @param ... (optional) Columns with grouping info, such as sample ID, treatment etc.
#' @param model Model to fit defaults to `drc::MM.2()`
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
