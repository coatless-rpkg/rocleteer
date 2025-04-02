# Test insert_examplesTempdir_template() function ----
test_that("insert_examplesTempdir_template(): function is defined", {
  # Check that the function exists
  expect_true(exists("insert_examplesTempdir_template"))
  expect_true(is.function(insert_examplesTempdir_template))
  
  # We can't easily test the RStudio API functionality directly
  # But we can check that the function attempts to use rstudioapi
  expect_error(insert_examplesTempdir_template(), "must be used within RStudio")
})
