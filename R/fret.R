#' Calculate fret.
#'
#' @param donor Donor fluorescent intensity.
#' @param acceptor Acceptor fluorescent intensity.
#'
#' @return
#' @export
#'
#' @examples
fret <- function(donor, acceptor) {
  donor / (donor + acceptor)
}
