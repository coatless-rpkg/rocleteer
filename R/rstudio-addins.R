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
