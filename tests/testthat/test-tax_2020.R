test_that("Tax Assessment for 2020 has not changed", {
  
  expect_equal_to_reference(tax_2020, "tax_2020.rds")
  
})
