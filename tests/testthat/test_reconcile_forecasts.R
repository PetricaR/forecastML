#------------------------------------------------------------------------------
# Test that reconcile_forecasts() works correctly.
library(forecastML)
library(dplyr)

test_that("reconcile_forecasts() works with various temporal aggregations", {

  #------------------------------------------------------------------------------
  # Example 1: 2 forecasts, daily/monthly, 2 forecast periods at highest aggregation.
  freq <- c("1 day", "1 month")

  data_1_day <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-2-29"), by = freq[1]),
                           "forecast" = c(rep(5, 31), rep(7, 29)))

  data_1_month <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-2-1"), by = freq[2]),
                             "forecast" = c(150, 200))

  forecasts_reconciled <- reconcile_forecasts(list(data_1_day, data_1_month), freq,
                                              index = "index", outcome = "forecast",
                                              method = "temporal")

  testthat::expect_equal(sum(forecasts_reconciled[[1]]$forecast), sum(forecasts_reconciled[[2]]$forecast), tolerance = .01)
  #------------------------------------------------------------------------------
  # Example 2: 3 forecasts, monthly/4-monthly/annually, 1 forecast period at highest aggregation.
  freq <- c("1 month", "4 months", "1 year")

  data_1_month <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-12-1"), by = freq[1]),
                             "forecast" = rep(10, 12))

  data_4_months <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-12-1"), by = freq[2]),
                              "forecast" = c(40, 50, 45))

  data_1_year <- data.frame("index" = as.Date("2020-01-01"),
                            "forecast" = c(110))

  forecasts_reconciled <- reconcile_forecasts(list(data_1_month, data_4_months, data_1_year), freq,
                                              index = "index", outcome = "forecast",
                                              method = "temporal")

  testthat::expect_equal(sum(forecasts_reconciled[[1]]$forecast), sum(forecasts_reconciled[[2]]$forecast), tolerance = .01)
  testthat::expect_equal(sum(forecasts_reconciled[[1]]$forecast), sum(forecasts_reconciled[[3]]$forecast), tolerance = .01)
  #------------------------------------------------------------------------------
  # Example 3: 2 forecasts, weekly/monthly, 2 forecast periods at highest aggregation.
  freq <- c("1 week", "1 month")

  data_1_week <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-3-1"), by = freq[1]),
                            "forecast" = c(rep(3, 5), rep(2, 4)))

  data_1_month <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-2-1"), by = freq[2]),
                             "forecast" = c(11, 12))

  forecasts_reconciled <- reconcile_forecasts(list(data_1_week, data_1_month), freq,
                                              index = "index", outcome = "forecast",
                                              method = "temporal")

  testthat::expect_equal(sum(forecasts_reconciled[[1]]$forecast), sum(forecasts_reconciled[[2]]$forecast), tolerance = .01)
  #------------------------------------------------------------------------------
  # Example 4: 2 forecasts, hourly/daily, 3 forecast periods at highest aggregation.
  freq <- c("1 hour", "1 day")
  timezone <- "UTC"

  data_1_hour <- data.frame("index" = seq(as.POSIXct("2020-01-01 00:00:00", tz = timezone),
                                          as.POSIXct("2020-01-03 23:00:00", tz = timezone),
                                          by = freq[1]),
                            "forecast" = rep(c(3, 5), 72 / 2))

  data_1_day <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-1-3"), by = freq[2]),
                           "forecast" = c(90, 100, 105))

  forecasts_reconciled <- reconcile_forecasts(list(data_1_hour, data_1_day), freq,
                                              index = "index", outcome = "forecast",
                                              method = "temporal")

  testthat::expect_equal(sum(forecasts_reconciled[[1]]$forecast), sum(forecasts_reconciled[[2]]$forecast), tolerance = .01)
})
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

test_that("reconcile_forecasts() handles out-of-bounds forecasts", {

  #------------------------------------------------------------------------------
  # Example 1: 2 forecasts, daily/monthly, 2 forecast periods at highest aggregation.
  freq <- c("1 day", "1 month")

  data_1_day <- data.frame("index" = seq(as.Date("2019-11-1"), as.Date("2020-3-15"), by = freq[1]),
                           "forecast" = 10)

  data_1_month <- data.frame("index" = seq(as.Date("2020-1-1"), as.Date("2020-2-1"), by = freq[2]),
                             "forecast" = c(150, 200))

  forecasts_reconciled <- reconcile_forecasts(list(data_1_day, data_1_month), freq,
                                              index = "index", outcome = "forecast",
                                              method = "temporal")

  testthat::expect_equal(sum(forecasts_reconciled[[1]]$forecast), sum(forecasts_reconciled[[2]]$forecast), tolerance = .01)
  #----------------------------------------------------------------------------
  # keep_all = FALSE
  forecasts_reconciled <- reconcile_forecasts(list(data_1_day, data_1_month), freq,
                                              index = "index", outcome = "forecast",
                                              method = "temporal", keep_all = FALSE)

  testthat::expect_true(methods::is(forecasts_reconciled, "data.frame"))
  #----------------------------------------------------------------------------
  # keep_non_reconciled = TRUE
  forecasts_reconciled <- reconcile_forecasts(list(data_1_day, data_1_month), freq,
                                              index = "index", outcome = "forecast",
                                              method = "temporal", keep_non_reconciled = TRUE)

  testthat::expect_true(all(forecasts_reconciled$`1 day`$index == data_1_day$index))
})
