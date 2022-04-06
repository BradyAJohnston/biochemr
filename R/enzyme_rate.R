#' Fit a Michaelis-Menton Curve to Enzymatic Data
#'
#' This function fits a Michaelis-Menton model to the dose-response data of
#' enzymatic reactions. By default the minimum rate is locked to 0, if you wish
#' to let the function find the minimum (if enzyme rate is > 0 at concentration
#' 0) then supply the `min = NA` or manually set it i.e. `min = 2.5`.
#'
#' @param data Data frame with columns for concentration, reaction rate and
#'   optionally grouping information.
#' @param conc Column containing the concentration data.
#' @param rate Column containing the enzyme rate data.
#' @param min Minimum value of enzyme rate. Defaults to 0, as if there is 0
#'   substrate there should be no enzymatic activity in a properly blanked
#'   experiment. Set to `NA` to allow the model to fit the minimum value.
#' @param group
#'
#' @return `tibble` with nested list columns of data, model, predictions,
#'  residuals and coefficients.
#' @export
#'
#' @examples
#' # Fitting MM curves to the enzymatic data inside of datasets::Puromycin
#' library(bicohemr)
#' df <- Puromycin %>%
#'   bio_enzyme_rate(conc, rate, state)
#'
#' # the result is a tibble with a column for the data, a column for the
#' # calculated # model and a column for the relevant coefficients extracted from
#' # the model
#' df
#'
#' # you can extract the coefficient data using either `bio_coefs()` or
#' # `unnest()` on the column
#' bio_coefs(df)
#' tidyr::unnest(df, coefs)
#'
#' # quick plot can be made for inspecing the results with `bio_plot()`
#' df %>%
#'   bio_plot()

bio_enzyme_rate <-
  function(data,
           conc,
           rate,
           group = NULL,
           min = 0) {

    # set minimum to 0
    model <- drc::MM.3(
      names = c("min", "Vmax", "Km"),
      fixed = c(min, NA, NA)
    )

    bio_dose_resp(
      data = data,
      .dose = {{ conc }},
      .resp = {{ rate }},
      .group = {{ group }},
      .model = model
    )
  }
