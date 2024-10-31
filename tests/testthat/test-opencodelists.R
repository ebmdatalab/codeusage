test_that("Download works with correct URLs", {
  url1 <- "https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bp_cod/20200812"
  url2 <- "https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bp_cod/20200812/"

  codelist <- get_opencodelist(url1)
  expect_equal(nrow(codelist), 97)

  codelist <- get_opencodelist(url2)
  expect_equal(nrow(codelist), 97)
})

test_that("Download fails with incorrect URLs", {
  invalid_url <- "https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bp_cod/2020"
  expect_error(get_opencodelist(invalid_url), "Error downloading codelist: HTTP 404 Not Found.")
})