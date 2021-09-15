#' Fitting of a Dose Response Model
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
      if (is.na(model)) {
        return(NA)
      }

      # find min and max non-zero dose values
      dose <- data %>%
        dplyr::filter(!is.na(dose),
               dose > 0) %>%
        dplyr::pull(dose)

      # create data.frame, from a dose sequence 10% below and above minimums
      from <- min(dose) * 0.9
      to <- max(dose) * 1.1

      preddf <- data.frame(dose = exp(seq(
        from = log(from),
        to = log(to),
        length.out = length(data$dose) * 10
      )))

      preddf <- cbind(preddf,
                      dplyr::as_tibble(stats::predict(model,
                                                      newdata = preddf,
                                                      interval = "confidence"))
                      )

      preddf %>%
        dplyr::rename(pred = Prediction, lower = Lower, upper = Upper)
    }

    results <- .data %>%
      dplyr::group_by(...) %>%
      tidyr::nest(
        raw = !c(dose, resp, ...),
        data = c(dose, resp)
      ) %>%
      purrr::quietly(dplyr::mutate)(
        # fit the drm model to the data in data
        drmod = purrr::map(data, purrr::possibly(drm.func, NA)),

        # use broom::augment to add residuals and other information from the fit
        # to the data column
        data = purrr::map2(drmod, data, purrr::possibly(broom::augment, data)),

        # create column of values that make up the 'prediction' for plotting the
        # fitted curve
        pred = purrr::map2(drmod, data, purrr::possibly(predict.fun, NA)),

        # create a column that contains all of the coefficients from the fitted
        # model, extracted using broom::tidy
        coefs = purrr::map(drmod, purrr::possibly(broom::tidy, NA))
      )

    results[[1]]
  }
