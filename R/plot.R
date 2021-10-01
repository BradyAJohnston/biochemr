#' Plot Data with Fitted  Models
#'
#' @param ... Additional `ggplot2::aes()` parameters to be applied to the plot.
#' @param facet Logical, whether to apply `ggplot2::facet_wrap()` based on the
#' @param data Tibble with nested columns of `data`, `drmod`, `line`, `coefs`
#'   made through one of the `b_binding()` or `b_enzyme_*()` functions.
#'   currently used facetting variables.
#' @return `ggplot2::ggplot()` object.
#' @importFrom rlang .data
#' @export
#' @examples
#' library(tidyverse)
#' Puromycin %>%
#'   b_enzyme_rate(conc, rate, state) %>%
#'   b_plot()
b_plot <- function(data, ..., facet = TRUE) {

  if (dplyr::is_grouped_df(data)) {
    group_vars <- dplyr::group_vars(data)
  } else {
    group_vars <- data %>%
      dplyr::select(!tidyselect::vars_select_helpers$where(is.list)) %>%
      names()
  }

  plt <- ggplot2::ggplot(data)

  point_data <- data %>% tidyr::unnest(.data$data)
  curve_data <- data %>% tidyr::unnest(.data$line)

  if (length(group_vars) > 0) plt <- plt + ggplot2::aes_string(group = group_vars)

  plt <- plt +
    ggplot2::aes(...) +
    ggplot2::geom_point(
      ggplot2::aes(x = .data$dose, y = .data$resp),
      data = point_data
    ) +
    ggplot2::geom_line(
      ggplot2::aes(x = .data$dose, y = .data$pred),
      data = curve_data
    ) +
    ggplot2::labs(x = "Dose", y = "Response") +
    ggplot2::theme_light() +
    ggplot2::theme(
      strip.text = ggplot2::element_text(colour = "black"),
      strip.background = ggplot2::element_rect(fill = NA, colour = "gray40")
    ) +
    ggplot2::scale_colour_discrete()

  if (facet & length(group_vars) != 0) {
    plt <- plt + ggplot2::facet_wrap(group_vars)
  }

  plt
}

#' Comparison Plot of Estimated Terms
#'
#' @details Creates a dot-and-whisker plot for quick comparison of estimated
#'   terms, also showing the calculated standard errors as errorbars.
#'
#' @param data Nested [`tibble`] that is the result from one of the fitting functions.
#' @param term Term to be plotted as string, i.e. `"kd"` or `"rate"`.
#' @param ... Additional arguments to be passed to `ggplot2::aes()` such as
#'   `colour = sample`.
#' @param pointSize Size of points, defaults to `3`.
#' @param group Column that results are grouped by.
#' @param errorBarHeight Relative height of the errorbars, defaults to `0.3`.
#'
#' @importFrom rlang .data
#' @return [`ggplot`] object
#' @export
#'
#' @examples
#'
#' DNase %>%
#' b_binding(conc, density, Run) %>%
#'   b_plot_coefs(Run, term = "kd", colour = Run)
b_plot_coefs <-
  function(data,
           group,
           term,
           ...,
           pointSize = 3,
           errorBarHeight = 0.3) {

    data <- data %>%
      b_coefs()

    data <- data[data$term %in% term,]

    data %>%
      ggplot2::ggplot(
        mapping = ggplot2::aes(
          x = .data$estimate,
          y = {{ group }},
          ...
        )
      ) +
      ggplot2::geom_errorbarh(
        ggplot2::aes(
          xmin = .data$estimate - .data$std.error,
          xmax = .data$estimate + .data$std.error
        ),
        colour = "black",
        height = errorBarHeight
      ) +
      ggplot2::geom_point(size = pointSize) +
      ggplot2::scale_colour_discrete() +
      ggplot2::theme_light() +
      ggplot2::theme(
        strip.background = ggplot2::element_rect(fill = "white", colour = "gray50"),
        strip.text = ggplot2::element_text(colour = "gray10")
      ) -> plt

    if (length(term) > 1) plt <-  plt + ggplot2::facet_wrap(~.data$term)

    plt

  }
