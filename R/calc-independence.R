#' Calculate the independence score
#' @param data A data frame
#' @export
#' @examples
#' library(broom)
#' step_count |>
#'   fit_logic_reg(response = unexpect,
#'                 predictors = too_many_high_days:min_day_too_low) |>
#'     augment() |>
#'     calc_miscla_rate(unexpect, .fitted) |>
#'     calc_independence()
calc_independence <- function(data){

  fit <- attr(data, "fit")
  response_nm <- colnames(fit$response)
  orig_data <- tibble::as_tibble(attr(data, "fit")$binary) |>
    dplyr::mutate(!!sym(response_nm) := as.vector(attr(data, "fit")$response))
  leaves <- unique(fit$model$trees[[1]]$trees$knot)
  vars_idx <- sort(leaves)[-1]
  used_vars <- colnames(fit$binary)[vars_idx]


  unexpected_df <- orig_data |> dplyr::filter(!!dplyr::sym(response_nm) == 1)
  used_df <- orig_data |> dplyr::select(!!!dplyr::syms(used_vars))
  multiinfo <- infotheo::multiinformation(used_df |> dplyr::select(!!!dplyr::syms(used_vars)))
  mi_per_obs <- multiinfo/nrow(unexpected_df)
  data |> dplyr::mutate(overlapping = mi_per_obs, independence = 1 - overlapping)
}

globalVariables(c("overlapping", ":="))
