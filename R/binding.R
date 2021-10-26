#' Calculate Binding Affinities
#'
#' Calculated binding affinities (Kd) from experimental data that contains dose
#' and response information. Could be titrated concentration and resulting
#' fluorescence, or percentage shift in a EMSA or something similar.
#'
#' @param data data.frame or tibble containing dose response data.
#' @param conc Column with the concentration information.
#' @param resp Column containing the response information.
#' @param ... Columns that contain the grouping information for the different
#'   samples in experiment (i.e. sample IDs, treatments etc).
#' @param slope For all 1:1 binding interactions, the slope for the log -
#'   logistic curve should be 1. If the interaction has some cooperativity or it
#'   is not a 1:1 binding interaction, then this value will change and should be
#'   allowed to be free (set `slope = NA`).
#' @return a [tibble][tibble::tibble-package]
#' @export
#'
#' @examples
#' Puromycin %>%
#'   b_enzyme_rate(conc, rate, state)
b_binding <-
  function(data,
           conc,
           resp,
           ...,
           slope = 1) {
    if (!is.numeric(slope)) {
      if (!is.na(slope)) {
        stop(
          "Slope must be numeric (likely 1) or set to NA for the model to guess."
        )
      }
    }

    model <- drc::LL.4(
      names = c("slope", "min", "max", "kd"),
      fixed = c(slope, NA, NA, NA)
    )

    b_dose_resp(data, {{ conc }}, {{ resp }}, ..., .model = model) %>%
      tibble::as_tibble()
  }
