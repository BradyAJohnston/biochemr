#' Plot Data with Fitted  Models
#'
#' @param ... Additional `ggplot2::aes()` parameters to be applied to the plot.
#' @param facet Logical, whether to apply `ggplot2::facet_wrap()` based on the
#' @param data Tibble with nested columns of `data`, `drmod`, `line`, `coefs`
#'   made through one of the `bio_binding()` or `bio_enzyme_*()` functions.
#' @param line_col
#' @param line_type
#' @param line_size
#' @param line_alpha
#' @param point_shape
#' @param point_col
#' @param point_alpha
#' @param point_size
#'   currently used facetting variables.
#' @return `ggplot2::ggplot()` object.
#' @importFrom rlang .data
#' @export
#' @examples
#' library(biochemr)
#' Puromycin %>%
#'   bio_enzyme_rate(conc, rate, group = state) %>%
#'   bio_plot()
bio_plot <- function(data,
                     ...,
                     facet = TRUE,
                     line_col = "black",
                     line_type = "solid",
                     line_size = 0.8,
                     line_alpha = 1,
                     point_shape = 21,
                     point_col = "black",
                     point_alpha = 1,
                     point_size = 1) {
  if (dplyr::is_grouped_df(data)) {
    group_vars <- dplyr::group_vars(data)
  } else {
    group_vars <- data %>%
      dplyr::select(!tidyselect::vars_select_helpers$where(is.list)) %>%
      names()
  }

  raw_data <- data$model[[1]]$data[, 1:2]
  name_dose <- colnames(raw_data)[1]
  name_resp <- colnames(raw_data)[2]
  point_data <- data %>% tidyr::unnest(.data$data)

  line_data <- data %>%
    dplyr::filter(!is.na(model)) %>%
    dplyr::mutate(
      line = purrr::map(model, func_predict)
    ) %>%
    dplyr::select(dplyr::all_of(group_vars), line) %>%
    tidyr::unnest(line)

  plt <- ggplot2::ggplot(point_data)

  if (length(group_vars) > 0) {
    plt <- plt + ggplot2::aes_string(group = group_vars)
  }

  plt <- plt +
    ggplot2::aes(...) +
    ggplot2::geom_point(
      ggplot2::aes_string(
        x = name_dose,
        y = name_resp
        ),
      # data = point_data,
      # shape = point_shape,
      # colour = point_col,
      # alpha = point_alpha,
      # size = point_size,
    ) +
    ggplot2::geom_line(
      ggplot2::aes_string(
        x = name_dose,
        y = name_resp
        ),
      data = line_data,
      # linetype = line_type,
      # size = line_size,
      # colour = line_col
    ) +
    ggplot2::labs(x = "Dose", y = "Response") +
    ggplot2::theme_light() +
    ggplot2::theme(
      strip.text = ggplot2::element_text(colour = "black"),
      strip.background = ggplot2::element_rect(fill = NA, colour = "gray40")
    ) +
    ggplot2::scale_colour_discrete()

    if (facet) plt <- plt + ggplot2::facet_wrap(group_vars)

    plt
  }

