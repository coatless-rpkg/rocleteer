#' Custom `@examplesTempdir` tag.
#'
#' This function generates example code that runs in a temporary directory
#' by automatically wrapping the code with the appropriate setup and teardown calls.
#' When roxygen2 processes your documentation, the `@examplesTempdir` tag is transformed into
#' an `@examples` tag with temporary directory handling, eliminating the need to manually
#' include these calls in your documentation.
#'
#' The tag addresses a common need when writing package examples that create files
#' or modify the filesystem. Running such examples in a temporary directory prevents
#' cluttering the user's working directory with test files and ensures clean package checks.
#'
#' @section Implementation:
#'
#' When the `@examplesTempdir` tag is processed, it is transformed into an `@examples` tag with
#' the following wrapper code automatically added:
#'
#' ```r
#' \dontshow{.old_wd <- setwd(tempdir())}
#'
#' # Your example code here
#'
#' \dontshow{setwd(.old_wd)}
#' ```
#' 
#' The temporary directory setup saves the current working directory, switches to `tempdir()`,
#' and then restores the original working directory when the example code has finished executing.
#' This is all hidden from the user in the final documentation using `\dontshow{}`.
#'
#' @section Use Cases:
#'
#' The `@examplesTempdir` tag is particularly useful for:
#'
#' * Examples that create or write to files
#' * Examples that need to test file operations
#' * Examples that should not modify the user's working directory
#' * Any code that should run in an isolated directory environment
#'
#' @section Package Configuration:
#'
#' To use the `@examplesTempdir` tag in your package, add `rocleteer` to your 
#' package dependencies and configure roxygen2 to use the `rocleteer`:
#'
#' In your `DESCRIPTION` file:
#' 
#' ```
#' Suggests:
#'     rocleteer
#' Remotes: coatless-rpkg/rocleteer
#' 
#' Roxygen: list(..., packages = c("rocleteer"))
#' ```
#' 
#' where `...` could be `roclets = c("collate", "namespace", "rd")`.
#' 
#' @name tag-examplesTempdir
#'
#' @usage
#' #' @examplesTempdir
#' #' # Your example code that needs to run in a temporary directory
#'
#' @examples
#' # A function that writes a file and needs to run in a temporary directory
#' # 
#' #' @title Write CSV to a File
#' #' @description 
#' #' This function writes a data frame to a CSV file
#' #' 
#' #' @param data     A data frame to write
#' #' @param filename Name of the file to write
#' #'
#' #' @return 
#' #' Invisibly returns the input data frame
#' #' 
#' #' @examplesTempdir
#' #' # Create a data frame
#' #' df <- data.frame(x = 1:5, y = letters[1:5])
#' #' 
#' #' # Write to a file
#' #' write.csv(df, "test.csv", row.names = FALSE)
#' #' 
#' #' # Check that the file exists
#' #' file.exists("test.csv")
#' #' 
#' #' # Read it back
#' #' read.csv("test.csv")
NULL

# Internal functions to handle the `@examplesTempdir` tag ----

#' Parse the `@examplesTempdir` tag
#'
#' This function handles the new `@examplesTempdir` tag, which automatically wraps 
#' example code in a pattern that temporarily changes to a temporary directory 
#' and restores the original directory afterward.
#'
#' @param x A roxygen2 tag
#' 
#' @return 
#' A parsed roxygen2 tag
#' 
#' @noRd
#' @exportS3Method roxygen2::roxy_tag_parse roxy_tag_examplesTempdir
roxy_tag_parse.roxy_tag_examplesTempdir <- function(x) {
  # Split the raw text into lines
  lines <- unlist(strsplit(x$raw, "\r?\n"))

  # Wrap the example code in the temporary directory setup and teardown
  x$raw <- paste(c(
    "\\dontshow{\n.old_wd <- setwd(tempdir()) # examplesTempdir\n}",
    paste(lines[-1], collapse = "\n"), # Skip the first line (empty newline)
    "\\dontshow{\nsetwd(.old_wd) # examplesTempdir\n}"
  ), collapse = "\n")
  
  # Revert the tag to `examples`
  x$tag <- "examples"
  
  # Process the tag as normal
  results <- roxygen2::tag_examples(x)
  
  results
}


#' @noRd
#' @exportS3Method roxygen2::roxy_tag_rd roxy_tag_examplesTempdir
roxy_tag_rd.roxy_tag_examplesTempdir <- function(x, base_path, env) {
  # Hook into the `roxygen2::rd_section_examples` function to handle the `@examplesTempdir` tag
  roxygen2::rd_section("examples", x$val)
}
