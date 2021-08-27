#' Fitting of a Dose Response Model
#'
#' @param .data Data frame contain columns for dose, response and if required
#'   grouping variables.
#' @param dose Column name for the dose data.
#' @param response Column name for the response data.
#' @param ... Columns by which to group the data before fitting models.
#' @param model Model function from `{drc}` to be fit to the data. Defaults to
#'   `drc::LL.4()` for the `b_dose_resp()` function.
#'
#' @return A `tibble()` with list-columns containing the data, the predictions,
#'   the residuals and the coefficients of the model.
#' @export
#'
#' @examples
b_dose_resp <-
  function(data,
           dose,
           response,
           ...,
           model = drc::LL.4(names = c("slope", "min", "max", "ec50"))) {

    # get the names of the columns from the dose and response arguments
    d <- deparse(substitute(dose))
    r <- deparse(substitute(response))

    # get the data from the dose and response columns
    data$d <- data[[d]] # e.g. data[["time"]]
    data$r <- data[[r]]

  drm.func <- function(x) {
    model <- tryCatch({
      drc::drm(r ~ d,
               fct = model,
               data = x
      )
    },
    error = function(cond) {
      message("Failed to fit model")
      return(NA)
    })

    model

  }

  # dataframe for predictions
  # add 10% below and above the data to the predictions
  # to generate log scale sequence for preddf:
  # exp(seq(log(from), log(to), length.out = length.out))
  from <- ifelse(min(data$d) <= 0,
                 0.1,
                 min(data$d, na.rm = TRUE) - (0.1 * min(data$d, na.rm = TRUE))
  )
  to <- max(data$d, na.rm = TRUE) + (0.1 * max(data$d, na.rm = TRUE))

  preddf <- data.frame(dose = exp(seq(
    from = log(from),
    to = log(to),
    length.out = length(data$d) * 10
  )))

  predict.fun <- function(x) {
    if(is.na(x)) return(NA)

    cbind(
      modelr::add_predictions(preddf, x),
      dplyr::as_tibble(stats::predict(x, newdata = preddf, interval = "confidence"))
    )
  }

  resid.fun <- function(x, y) {
    if(is.na(y)) return(NA)
    modelr::add_residuals(as.data.frame(x), model = y) %>%
      dplyr::as_tibble()
  }

  coefs.fun <- function(x) {
    if(is.na(x)) return(NA)
    stats::coef(x) %>%
      dplyr::tibble(parameter = names(.), value = .) # instead of tidy()
  }


  results <- data %>%
    dplyr::group_by(...) %>%
    tidyr::nest() %>%
    purrr::quietly(dplyr::mutate)(
      drmod = purrr::map(data, drm.func),
      resid = purrr::map2(data, drmod, resid.fun),
      pred = purrr::map(drmod, predict.fun),
      coefs = purrr::map(drmod, coefs.fun)
    )

  results[[1]]
}
