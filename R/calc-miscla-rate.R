#' Calculate the misclassification rate (precision, recall, F1)
#' @param data A data frame
#' @param pred The column name of the predicted values
#' @param true The column name of the true values
#' @param include_f1 Whether to include F1 score
#' @export
#' @examples
#' library(broom)
#' step_count |>
#'   fit_logic_reg(response = unexpect,
#'                 predictors = too_many_high_days:min_day_too_low) |>
#'   augment() |>
#'   calc_miscla_rate(unexpect, .fitted)
calc_miscla_rate <- function(data, pred, true, include_f1 = FALSE){
  tbl <- table(data[[dplyr::ensym(pred)]], data[[dplyr::ensym(true)]])

  # (pred/fit)      0     1
  #         0    1440   457
  #         1    1800  2783
  # precision = TP/ (TP + FP) = 2783 / (2783 + 1800) = 0.607
  # recall = TP / (TP + FN) = 2783 / (2783 + 457) = 0.858

  if (nrow(tbl) == 2 & ncol(tbl) == 2){
    res <- tibble(precision = tbl[2,2] / (tbl[2,2] + tbl[2,1]),
                  recall = tbl[2,2] / (tbl[2,2] + tbl[1,2]))
  } else if (as.numeric(rownames(tbl)) == 1) {
    res <- tibble(precision = tbl[1,2] / (tbl[1,2] + tbl[1,1]), recall = 1)
  } else {
    stop("The confusion matrix is not 2x2.")
  }

  if (include_f1){
    res <- res |> dplyr::mutate(F1 = 2 * (precision * recall) / (precision + recall))
  }

  attr(res, "fit") <- attr(data, "fit")
  attr(res, "data") <- data
  return(res)
}

#' Calculate combined metrics from precision, recall and independence
#' @param data A data frame
#' @param metrics A character vector of metrics to calculate, including harmonic,
#' square_root, arithmetic, geometric, contraharmonic means
#' @param include_original Whether to include the original columns
#' @export
#' @rdname metrics
#' @examples
#' library(broom)
#' step_count |>
#'   fit_logic_reg(response = unexpect,
#'                 predictors = too_many_high_days:min_day_too_low) |>
#'   augment() |>
#'   calc_miscla_rate(unexpect, .fitted) |>
#'   calc_independence() |>
#'   calc_metrics(metrics = c("harmonic", "arithmetic"))
calc_metrics <- function(data, metrics = c("harmonic", "square_root",
                                         "arithmetic", "geometric",
                                         "contraharmonic"),
                            include_original = TRUE){
  # TODO: check it has precision, recall, independence
  res <- purrr::map(
    metrics,
    ~ data |> dplyr::mutate(!!dplyr::sym(.x) := rlang::eval_tidy(!!get(.x)),
                         .keep = "none")) |>
    bind_cols()

  if (include_original) res <- data |> dplyr::bind_cols(res)
  return(res)
}

#' @export
#' @rdname metrics
harmonic <- dplyr::quo(3 / (1/precision + 1/recall + 1/independence))

#' @export
#' @rdname metrics
square_root <- dplyr::quo(sqrt((precision^2 + recall^2 + independence^2)/3))

#' @export
#' @rdname metrics
arithmetic <- dplyr::quo((precision + recall + independence)/3)

#' @export
#' @rdname metrics
geometric <- dplyr::quo((precision * recall * independence)^(1/3))

#' @export
#' @rdname metrics
contraharmonic <- dplyr::quo((precision^2 + recall^2 + independence^2) /
                             (precision + recall + independence))

globalVariables(c("precision", "recall"))
