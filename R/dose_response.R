#' Fitting of a Dose Response Model
#'
#' Generic internal function for fitting of dose-response models with the output
#' in a _tidy_ format. Results include nested columns of raw data, fitted
#' models, model parameters and curve data for plotting.
#'
#' @param .data Data frame contain columns for dose, response and if required
#'   grouping variables.
#' @param .dose Column name for the dose data.
#' @param .resp Column name for the response data.
#' @param ... Columns by which to group the data before fitting models.
#' @param .model Model function from `{drc}` to be fit to the data. Defaults to
#'   `drc::LL.4()` for the `b_dose_resp()` function.
#'
#' @return A `tibble()` with list-columns containing the data, the predictions,
#'   the residuals and the coefficients of the model.
#' @export
#'
#' @examples
#' DNase %>%
#'   b_dose_resp(conc, density, Run)
b_dose_resp <-
  function(.data,
           .dose,
           .resp,
           ...,
           .model = drc::LL.4(names = c("slope", "min", "max", "ec50"))) {

    .data <- .data %>%
      dplyr::mutate(
        dose = {{ .dose }},
        resp = {{ .resp }}
      )

    drm.func <- function(x) {
      drc::drm(resp ~ dose,
        fct = .model,
        data = x
      )
    }



    predict.fun <- function(model, data) {
      if (!(methods::is(model) %in% c("drc"))) {
        return(NA)
      }

      dose_vector <- data$dose[data$dose > 0 & !is.na(data$dose)]

      # find min and max and go 10% above and below
      from <- min(dose_vector) * 0.9
      to <- max(dose_vector) * 1.1

      # create df for the curve, using min and max. Work in log / exp space
      # so that the curve is consistent when plotting on scale_x_log10()
      preddf <- data.frame(dose = exp(seq(
        from = log(from),
        to = log(to),
        length.out = length(dose_vector) * 10
      )))

      # add the values along with confidence to the data frame
      preddf <- cbind(preddf,
                      dplyr::as_tibble(stats::predict(model,
                                                      newdata = preddf,
                                                      interval = "confidence"))
                      )

      # rename to make all columns lowercase and return tibble
      dplyr::rename(.data = preddf,
                    pred = .data$Prediction,
                    lower = .data$Lower,
                    upper = .data$Upper)
    }

    results <- .data %>%
      # dplyr::group_by(..., .add = TRUE) %>%
      tidyr::nest(
        raw = !c(.data$dose, .data$resp, ...),
        data = c(.data$dose, .data$resp)
      ) %>%
      purrr::quietly(dplyr::mutate)(
        # fit the drm model to the data in data
        drmod = purrr::map(.data$data, purrr::possibly(drm.func, NA)),

        # use broom::augment to add residuals and other information from the fit
        # to the data column
        data = purrr::map2(.data$drmod, .data$data, purrr::possibly(broom::augment, .data$data)),

        # create column of values that make up the 'prediction' for plotting the
        # fitted curve
        line = purrr::map2(.data$drmod, .data$data, purrr::possibly(predict.fun, NA)),

        # create a column that contains all of the coefficients from the fitted
        # model, extracted using broom::tidy()
        coefs = purrr::map(.data$drmod, purrr::possibly(broom::tidy, NA))
      )

    # return the results of purrr::quietly() and not the warnings generated
    tibble::as_tibble(results[[1]])
  }
