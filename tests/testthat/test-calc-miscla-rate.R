library(dplyr)
library(tibble)
test_that("misclassificaiton calculation works", {

  set.seed(123)
  dt <- tibble(pred = sample(0:1, 10000, replace = TRUE),
               true = sample(0:1, 10000, replace = TRUE))
  precision <- table(dt)[2,2] / (table(dt)[2,2] + table(dt)[2,1])
  recall <- table(dt)[2,2] / (table(dt)[2,2] + table(dt)[1,2])
  res <- dt |> calc_miscla_rate(pred, true, include_f1 = TRUE)
  expect_equal(res$precision, precision)
  expect_equal(res$recall, recall)

  # work when only one class
  dt2 <- dt |> filter(pred == 1)
  precision <- table(dt2)[1,2] / (table(dt2)[1,2] + table(dt2)[1,1])
  recall <- 1
  res <- dt2 |> calc_miscla_rate(pred, true, include_f1 = TRUE)
  expect_equal(res$precision, precision)
  expect_equal(res$recall, recall)

  # work when only one class
  dt3 <- dt |> filter(!((pred == 0) & (true == 1)))
  precision <- table(dt3)[2,2] / (table(dt3)[2,2] + table(dt3)[2,1])
  recall <- table(dt3)[2,2] / (table(dt3)[2,2] + table(dt3)[1,2])
  res <- dt3 |> calc_miscla_rate(pred, true, include_f1 = TRUE)
  expect_equal(res$precision, precision)
  expect_equal(res$recall, recall)
})


test_that("metric calculation works", {

  set.seed(123)
  dt <- tibble(pred = sample(0:1, 10000, replace = TRUE),
               true = sample(0:1, 10000, replace = TRUE))
  res <- dt |> calc_miscla_rate(pred, true) |>
    dplyr::mutate(independence = 0.8) |>
    calc_metrics()

  harmonic <- 3 / (1/res$precision + 1/res$recall + 1/0.8)
  square_root <- sqrt((res$precision^2 + res$recall^2 + 0.8^2)/3)
  arithmetic <- (res$precision + res$recall + 0.8)/3
  geometric <- (res$precision * res$recall * 0.8)^(1/3)
  contraharmonic <- (res$precision^2 + res$recall^2 + 0.8^2) /
    (res$precision + res$recall + 0.8)

  expect_equal(res$harmonic, harmonic)
  expect_equal(res$square_root, square_root)
  expect_equal(res$arithmetic, arithmetic)
  expect_equal(res$geometric, geometric)
  expect_equal(res$contraharmonic, contraharmonic)


})
