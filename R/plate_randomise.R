
pl <- data.frame(well = paste0(rep(LETTERS[1:8], each = 12), 1:12))

some_sample <- function(x, seed = 2) {
  set.seed(2)
  sample(x, length(x))
}

some_sample(pl$well)



