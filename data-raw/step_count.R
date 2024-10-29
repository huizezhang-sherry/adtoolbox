## code to prepare `step-count` dataset goes here
library(tidyverse)
set.seed(123)
step_count <- tibble(id = 1:300) |>
  rowwise() |>
  mutate(
    x = list(round(rnorm(5, 9000, sd = 3000), 0)),
    m = mean(x),
    unexpect = ifelse(between(m, 7500, 10500), 0, 1),
    x_sorted = list(sort(x)),
    too_many_high_days = ifelse(x_sorted[4] > 11000 & x_sorted[2] > 8000, 1, 0),
    too_many_low_days = ifelse(x_sorted[2] < 8000 & x_sorted[4] < 11000, 1, 0),
    max_day_too_high = ifelse(x_sorted[5] > 14000 &
                                (x_sorted[1] + x_sorted[5]) / 2 > 10000,
                              1, 0),
    min_day_too_low = ifelse(x_sorted[1] < 5000 &
                               (x_sorted[1] + x_sorted[5])/2 < 8000,
                             1, 0)) |>
  ungroup()


usethis::use_data(step_count, overwrite = TRUE)
