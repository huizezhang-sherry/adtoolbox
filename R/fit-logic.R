#' Fit logic regression
#' @param data A tibble
#' @param response the response variable
#' @param predictors the predictors
#' @param ... others
#' @export
#' @examples
#' library(broom)
#' step_count |>
#'    fit_logic_reg(response = unexpect,
#'                  predictors = too_many_high_days:min_day_too_low) |>
#'    augment()
fit_logic_reg <- function(data, response, predictors, ...){

  resp <- data |> dplyr::select(!!dplyr::enquo(response)) |>  as.matrix()
  pred <- data |> dplyr::select(!!!dplyr::enquos(predictors)) |> as.data.frame()

  # type = 1 for classification select = 1: fit a single model
  fit <- LogicReg::logreg(resp = resp, bin = pred, type = 1, select = 1, ...)

  return(fit)

}


#' Augment logic regression
#' @param x description
#' @param data description
#' @param ... others
#' @export
#' @method augment logreg
augment.logreg <- function(x, data = NULL, ...) {

  if (is.null(data)) data <- cbind(x$resp, x$bin)
  res <- tibble::as_tibble(data) |> dplyr::mutate(.fitted = predict(x, data))
  attr(res, "fit") <- x
  return(res)
}

globalVariables(c("predict"))
