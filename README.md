
<!-- README.md is generated from README.Rmd. Please edit that file -->

# biochemr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

The goal of `{biochemr}` is to create a user-friendly one-stop-shop
interface to a range of R packages to help with reproducible analysis of
common biochemistry experiments.

`{biochemr}` provides a common and consistent interface to a range of
packages for analysis of results, following the `{tidyverse}`
conventions to make most things easier, at the cost of making some niche
things harder.

The documentation and tutorials that make up `{biochemr}` assume the
user will have very little experience with R and programming in general
- placing emphasis on newcomer friendly documentation over brevity.

## Installation

You can install the released version of biochemr from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("biochemr")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("BradyAJohnston/biochemr")
```

## Example

Analaysis enzyme rate experiments.

#### Experimetal Data

``` r
head(Puromycin)
#>   conc rate   state
#> 1 0.02   76 treated
#> 2 0.02   47 treated
#> 3 0.06   97 treated
#> 4 0.06  107 treated
#> 5 0.11  123 treated
#> 6 0.11  139 treated
```

``` r
library(biochemr)
df <- b_enzyme_rate(Puromycin, conc, rate, state)

df
#> # A tibble: 2 × 6
#> # Groups:   state [2]
#>   state     data              drmod  resid             pred           coefs     
#>   <fct>     <list>            <list> <list>            <list>         <list>    
#> 1 treated   <tibble [12 × 4]> <drc>  <tibble [12 × 5]> <df [230 × 5]> <tibble […
#> 2 untreated <tibble [11 × 4]> <drc>  <tibble [11 × 5]> <df [230 × 5]> <tibble […
```

The result is a tibble (like a data.frame) that has a row for each
sample and a column the relevant data for each. The original data is in
`data`, the fitted model is in `drmod`, the residuals for the model in
`resid`, the predictions for the fitted curve (to draw the line) in
`pred` and the coefficients (Vmax, Km) in `coefs`.

To extract relevant coefficients, use `b_params()`.

``` r
df %>% b_params()
#> Adding missing grouping variables: `state`
#> # A tibble: 2 × 3
#> # Groups:   state [2]
#>   state      Vmax     Km
#>   <fct>     <dbl>  <dbl>
#> 1 treated    213. 0.0641
#> 2 untreated  160. 0.0477
```

To plot plot the data quickly, use

# Roadmap

The plan is to add support for as many types of analysis for experiments
in biochemistry as possible. A list of planned and currently supported
approaches are below. Please open an issue or make a pull request to add
analysis you would like to see supported.

Experimental analysis to be supported by `{biochemr}`:

-   [x] Ligand binding experiments for calculating `Kd`.
-   [x] Enzyme rate experiments for calculating `Vmax` and `Km`
-   [ ] qPCR Experimental Analysis
-   [ ] Replotting of FPLC / HPLC Traces for *aesthic* and informative
    chromatograms.
