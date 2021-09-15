#' Plot Data with Fitted  Models
#'
#' @param .data Data frame with nested columns of data, models and predictions.
#' @param ... Additional `ggplot2::aes()` parameters to be applied to the plot.
#' @param .facet Logical, whether to apply `ggplot2::facet_wrap()` based on the
#'   currently used facetting variables.
#' @param .annotate Logical, whether to automatically add labels to the plots
#'   containing the relevant coefficient information from the model.
#'
#' @return `ggplot2::ggplot()` object.
#' @export
#'
#' @examples
b_plot <- function(data, ..., .facet = TRUE) {

  if (dplyr::is_grouped_df(data)) {
    group_vars <- dplyr::group_vars(data)
  } else {
    group_vars <- data %>%
      dplyr::select(!where(is.list)) %>%
      names()
  }

  plt <- ggplot2::ggplot(data)

  if (length(group_vars) > 0) plt <- plt + ggplot2::aes_string(group = group_vars)

  plt <- plt +
    ggplot2::aes(x = dose, ...) +
    ggplot2::geom_point(
      ggplot2::aes(y = resp),
      data = data %>%
        tidyr::unnest(data)
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = pred),
      data = data %>%
        tidyr::unnest(pred)
    ) +
    ggplot2::theme_light() +
    ggplot2::theme(
      strip.text = ggplot2::element_text(colour = "black"),
      strip.background = ggplot2::element_rect(fill = NA, colour = "gray40")
    ) +
    ggplot2::scale_colour_discrete()

  if (.facet & length(group_vars) != 0) plt <- plt + ggplot2::facet_wrap(group_vars)

  plt
}
