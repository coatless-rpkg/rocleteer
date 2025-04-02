# Mock documents to parse
mock_examplesTempdir_document <- function() {
  "
    #' Document title
    #'
    #' Description discussing function implementation
    #'
    #' @param x,y A number
    #' @param z   A logical
    #' 
    #' @return 
    #' Nothing!
    #' 
    #' @details
    #' Complicated function
    #' 
    #' @export
    #' @examplesTempdir
    #' awesome_function(1, 2, TRUE)
    awesome_function <- function(x, y, z = FALSE) {
      return(x + y + (z == TRUE)*1)
    } 
  "
}

mock_double_examplesTempdir_document <- function() {
  "
    #' Document title
    #'
    #' Description discussing function implementation
    #'
    #' @param x,y A number
    #' @param z   A logical
    #' 
    #' @return 
    #' Nothing!
    #' 
    #' @details
    #' Complicated function
    #' 
    #' @export
    #' @examples
    #' 1 + 1
    #' @examplesTempdir
    #' awesome_function(1, 2, TRUE)
    awesome_function <- function(x, y, z = FALSE) {
      return(x + y + (z == TRUE)*1)
    } 
  "
}


# Test roxy_tag_parse.roxy_tag_examplesTempdir() function ----
test_that("roxygen2::parse_text(): parses `@examplesTempdir` correctly ", {
  # Create a document with examplesTempdir tag
  document_text <- mock_examplesTempdir_document()
  
  # Parse the tag
  expect_silent(block <- roxygen2::parse_text(document_text)[[1]])
  
  # Check the result no longer has an `examplesTempdir` tag
  expect_true(roxygen2::block_has_tags(block, "examples"))
  
  # Verify example content is parsed with the `dontshow` hack
  expect_identical(
    roxygen2::block_get_tag(block, "examples")$raw,
    "\\dontshow{\n.old_wd <- setwd(tempdir()) # examplesTempdir\n}\nawesome_function(1, 2, TRUE)\n\\dontshow{\nsetwd(.old_wd) # examplesTempdir\n}"
  )
})


# Test roxygen2::rd_roclet() function ----
test_that("roxygen2::rd_roclet(): generates correct Rd with `@examplesTempdir`", {
  # Create a document with examplesTempdir tag
  document_text <- mock_examplesTempdir_document()
  
  # Process the document
  results <- roxygen2::roc_proc_text(roxygen2::rd_roclet(), document_text)
  
  # Extract the examples section
  current_examples <- results$awesome_function.Rd$get_section("examples")
  
  # Check the result
  expected <- paste0(c(
    "\\dontshow{",
    ".old_wd <- setwd(tempdir()) # examplesTempdir",
    "}",
    "awesome_function(1, 2, TRUE)",
    "\\dontshow{",
    "setwd(.old_wd) # examplesTempdir",
    "}"
  ), collapse = "\n")
  
  expect_equal(current_examples$type, "examples")
  expect_equal(unclass(current_examples$value), expected)
})


test_that("roxygen2::rd_roclet(): generates correct Rd with both `@examples` and `@examplesTempdir`", {
  # Create a document with examplesTempdir tag
  document_text <- mock_double_examplesTempdir_document()
  
  # Process the document
  results <- roxygen2::roc_proc_text(roxygen2::rd_roclet(), document_text)
  
  # Extract the examples section
  current_examples <- results$awesome_function.Rd$get_section("examples")
  
  # Check the result
  expected <- c(
    "1 + 1",
    paste0(
      c(
        "\\dontshow{",
        ".old_wd <- setwd(tempdir()) # examplesTempdir",
        "}",
        "awesome_function(1, 2, TRUE)",
        "\\dontshow{",
        "setwd(.old_wd) # examplesTempdir",
        "}"
      ),
      collapse = "\n")
  )
  
  expect_equal(current_examples$type, "examples")
  expect_equal(unclass(current_examples$value), expected)
})

