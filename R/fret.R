#' Calculate fret.
#'
#' A
#' @param donor Donor fluorescent intensity.
#' @param acceptor Acceptor fluorescent intensity.
#'
#' @return Vector of calculated fret intensities.
#' @export
#'
#' @examples
fret <- function(donor, transfer) {
  transfer / (donor + transfer)
}
