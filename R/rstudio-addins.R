#' Insert a temporary working directory template
#'
#' This function inserts a template for the `@examplesTempdir` tag at the cursor position.
#' It's designed to be used as an RStudio addin.
#'
#' @export
insert_examplesTempdir_template <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE) || !rstudioapi::isAvailable()) {
    stop("This function must be used within RStudio")
  }
  
  template <- paste(
    "#' @examplesTempdir",
    "#' # Your code here",
    sep = "\n"
  )
  
  rstudioapi::insertText(template)
}

#' Insert a webR examples template
#'
#' This function inserts a template for the `@examplesWebR` tag at the cursor position.
#' It's designed to be used as an RStudio addin.
#'
#' @export
insert_examplesWebR_template <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE) || !rstudioapi::isAvailable()) {
    stop("This function must be used within RStudio")
  }
  
  template <- paste(
    "#' @examplesWebR",
    "#' # Your interactive R code here",
    "#' plot(1:10, 1:10)",
    sep = "\n"
  )
  
  rstudioapi::insertText(template)
}
