#' Title
#'
#' @param data
#' @param .dose
#' @param .resp
#' @param .model
#'
#' @return
#'
#' @examples
func_drm <- function(data, .dose, .resp, .model) {
  # do rlang-magic to accept user-column names in a formula
  in_dose <- dplyr::sym(rlang::quo_name(rlang::enquo(.dose)))
  in_resp <- dplyr::sym(rlang::quo_name(rlang::enquo(.resp)))
  .f <- rlang::expr(!!in_resp ~ !!in_dose)
  # fit the model

  mod <- drc::drm(
    formula = .f,
    fct = .model,
    data = data
  )
  # return the model
  mod
}



#' Title
#'
#' @param model
#'
#' @importFrom rlang .data :=
#' @return
#'
#' @examples
func_predict <- function(model) {
  if (!(methods::is(model, "drc"))) {
    return(NA)
  }

  raw_data <- tibble::as_tibble(model$data[, 1:2])
  name_dose <- colnames(raw_data)[1]
  name_resp <- colnames(raw_data)[2]

  raw_dose <- dplyr::pull(raw_data, !!name_dose)
  min_dose <- min(raw_dose, na.rm = TRUE)
  max_dose <- max(raw_dose, na.rm = TRUE)

  # create df for the curve, using min and max. Work in log / exp space
  # so that the curve is consistent when plotting on scale_x_log10()
  preddf <- tibble::tibble(
    !!name_dose := exp(seq(
      from = log(min_dose),
      to = log(max_dose),
      length.out = nrow(raw_data) * 10
    ))
  )

  predictions <- broom::augment(model, newdata = preddf) %>%
    dplyr::select(
      !!name_dose,
      !!name_resp := .fitted
    )

  predictions
}
#' Fitting of a Dose Response Model
#'
#' Generic internal function for fitting of dose-response models with the output
#' in a _tidy_ format. Results include nested columns of raw data, fitted
#' models, model parameters and curve data for plotting.
#'
#' @param .dose Column name for the dose data.
#' @param .resp Column name for the response data.
#' @param .model Model function from `{drc}` to be fit to the data. Defaults to
#'   `drc::LL.4()` for the `bio_dose_resp()` function.
#' @param data
#' @param .group
#'
#' @importFrom rlang .data
#'
#' @return A `tibble()` with list-columns containing the data, the predictions,
#'   the residuals and the coefficients of the model.
#' @export
#'
#' @examples
#' DNase %>%
#'   bio_dose_resp(conc, density, Run)
bio_dose_resp <-
  function(data,
           .dose,
           .resp,
           .group = NULL,
           .model = drc::LL.4(names = c("slope", "min", "max", "ec50"))) {


    results <- data %>%
      dplyr::group_by({{ .group }}, .add = TRUE) %>%
      tidyr::nest() %>%
      purrr::quietly(dplyr::mutate)(
        # fit the drm model to the experimental data that is nested
        model = purrr::map(data, purrr::possibly(
          ~ func_drm(
            data = .x,
            .dose = {{ .dose }},
            .resp = {{ .resp }},
            .model = .model
          ),
          NA
        )),

        # create a column that contains all of the coefficients from the fitted
        # model, extracted using broom::tidy()
        coefs = purrr::map(.data$model, purrr::possibly(
          ~ dplyr::select(broom::tidy(.x), -"curve"),
          NA
        ))
      )

    # return the results of purrr::quietly() and not the warnings generated
    tibble::as_tibble(results[[1]])
  }
