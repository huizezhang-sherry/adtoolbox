# nocov start
#' @importFrom vctrs s3_register
.onLoad <- function(...){
  vctrs::s3_register("broom::augment", "logreg")
}
# nocov end
