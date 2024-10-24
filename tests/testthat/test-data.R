test_that("Test snomed_usage column names", {
  test_names <- names(snomed_usage)
  expect_equal(
    test_names,
    c(
      "start_date",
      "end_date",
      "snomed_concept_id",
      "description",
      "usage",
      "active_at_start",
      "active_at_end"
    )
  )
})


test_that("Test snomed_usage column types", {
  expect_s3_class(snomed_usage$start_date, "Date")
  expect_s3_class(snomed_usage$end_date, "Date")
  expect_type(snomed_usage$snomed_concept_id, "character")
  expect_type(snomed_usage$description, "character")
  expect_type(snomed_usage$usage, "integer")
  expect_type(snomed_usage$active_at_start, "logical")
  expect_type(snomed_usage$active_at_end, "logical")
  
})


test_that("Test snomed_usage rows", {
  test_nrow <- nrow(snomed_usage)
  expect_equal(test_nrow, 1523967L)
})

test_that("Test snomed_usage date range", {
  test_range_start_date <- range(snomed_usage$start_date)
  test_range_end_date <- range(snomed_usage$end_date)

  expect_equal(
    test_range_start_date,
    c(as.Date("2011-08-01"), as.Date("2023-08-01"))
  )
  expect_equal(
    test_range_end_date,
    c(as.Date("2012-07-31"), as.Date("2024-07-31"))
  )
})

test_that("Test sum of usage", {
  test_usage_sum <- sum(snomed_usage$usage)
  expect_equal(test_usage_sum, 41721589830)
})
