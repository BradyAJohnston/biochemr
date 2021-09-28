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
