#' Plot the logic regression output
#' @param x A logic regression model output from [fit_logic_reg] or [LogicReg::logreg()]
#' @param names A vector of names for the variables
#' @examples
#' fit <- step_count |>
#'   fit_logic_reg(response = unexpect,
#'                 predictors = too_many_high_days:min_day_too_low,
#'                 nleaves = 4, seed = 1234)
#' plot_logicreg(fit)
#' @export
#'
plot_logicreg <- function(x, names){
  #browser()
  stopifnot(class(x) == "logreg")

  if (length(x$model$trees) != 1) {
    stop("plotting only works for single tree models")
  }

  dt <- x$model$trees[[1]]$trees
  if (missing(names)){names <- x$binnames}
  dt$knot <- purrr::map(dt$knot, ~if(.x ==0) {0} else{names[.x]})
  dt$x <- 0
  dt$y <- 0
  dt <- dt |> dplyr::mutate(
    knot = ifelse(knot == "0" & conc == 2, "OR", knot),
    knot = ifelse(knot == "0" & conc == 1, "AND", knot)
    )

  level <- ceiling(log(1 + max(dt$number))/log(2))
  max_p <- 2^level - 1
  # adopt from LogicReg:::plot.logregtree
  for (k in level:1) {
    y.val <- (-k)
    min.val <- 2^(-y.val - 1)
    diff.x <- 1/(min.val + 1)
    x.val <- seq(diff.x, 1 - diff.x, diff.x)
    for (j in 1:length(x.val)) {
      which <- 2^(k - 1) + j - 1
      if (which <= nrow(dt)){
        dt$x[which] <- x.val[j]
        dt$y[which] <- y.val[]
      }
    }
  }

  dt <- dt |> dplyr::filter(pick == 1)
  dt2 <- dt |> mutate(level = ceiling(log(number+1) / log(2)))
  line_df <- purrr::map_dfr(1:max(dt2$level - 1), function(idx){
    tibble::as_tibble(dt2) |>
      dplyr::filter(level %in% c(idx, idx + 1)) |>
      mutate(group = number, group = ifelse(level == idx + 1, number %/% 2, group))
    })

  dt |>
    ggplot2::ggplot() +
    ggplot2::geom_line(data = line_df, alpha = 0.5,
                       ggplot2::aes(x = x, y = y, group = group),) +
    ggplot2::geom_label(
      ggplot2::aes(x = x, y = y, label = knot,
                   color = as.factor(neg), fill = as.factor(neg)), parse = TRUE) +
    ggplot2::scale_fill_manual(values = c("#ffffff", "#000000")) +
    ggplot2::scale_color_manual(values = c("#000000", "#ffffff" )) +
    ggplot2::theme_void() +
    ggplot2::xlim(0, 1) +
    ggplot2::theme(legend.position = "none")

}

globalVariables(c("conc", "group", "knot", "number", "pick", "y", "neg"))

