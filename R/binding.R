#' Calculate Binding Affinities
#'
#' Calculated binding affinities (Kd) from experimental data that contains dose
#' and response information. Could be titrated concentration and resulting
#' fluorescence, or percentage shift in a EMSA or something similar.
#'
#' @param data data.frame or tibble containing dose response data.
#' @param conc Column with the concentration information.
#' @param resp Column containing the response information.
#' @param ... Columns that contain the grouping information for different
#'   samples.
#' @param model Model to fit. Defaults to `drc::LL.4()` for log-logistic
#'   dose-response model for binding.
#'
#' @return A `tibble()` with list-columns containing the data, the predictions,
#'   the residuals and the coefficients of the model.
#' @export
#'
#' @examples
b_binding <-
  function(data,
           conc,
           resp,
           ...,
           model = drc::LL.4(names = c("slope", "min", "max", "kd"))) {
    biochemr::b_dose_resp(data,
                          dose = conc,
                          response = resp,
                          ... = ...,
                          model = model)
  }
