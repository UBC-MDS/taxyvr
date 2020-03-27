test_that("Tax Assessment for 2018 has not changed", {
  
  expect_equal_to_reference(tax_2018, "tax_2018.rds")
  
})
