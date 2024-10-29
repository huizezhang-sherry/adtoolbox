
<!-- README.md is generated from README.Rmd. Please edit that file -->

# adtoolbox

<!-- badges: start -->

[![R-CMD-check](https://github.com/huizezhang-sherry/adtoolbox/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/huizezhang-sherry/adtoolbox/actions/workflows/R-CMD-check.yaml)
[![test](https://github.com/huizezhang-sherry/adtoolbox/actions/workflows/test.yaml/badge.svg)](https://github.com/huizezhang-sherry/adtoolbox/actions/workflows/test-coverage.yaml)
<!-- badges: end -->

## Installation

You can install the released version of adtoolbox from CRAN with:

    install.packages("adtoolbox")

And the development version from GitHub with:

    # install.packages("remotes")
    remotes::install_github("huizezhang-sherry/adtoolbox")

# Example

``` r
library(adtoolbox)
library(broom)
step_count |> 
  fit_logic_reg(response = unexpect, 
                predictors = too_many_high_days:min_day_too_low) |> 
  augment() |> 
  calc_miscla_rate(unexpect, .fitted) |> 
  calc_independence() |> 
  calc_metrics(metrics = c("harmonic", "arithmetic"))
#> # A tibble: 1 × 6
#>   precision recall overlapping independence harmonic arithmetic
#>       <dbl>  <dbl>       <dbl>        <dbl>    <dbl>      <dbl>
#> 1     0.633  0.794     0.00343        0.997    0.781      0.808
```
