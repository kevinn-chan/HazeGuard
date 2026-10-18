# tests/test_01a_hist.R
source("R/00_fns_data.R")
h <- read_hist("data/raw/psi_hist.csv")
at <- function(t) h[format(h$time, "%Y-%m-%d %H:%M") == t, ]
stopifnot(
  nrow(h) == 108864, !anyDuplicated(h$time),
  all(diff(as.numeric(h$time)) == 3600),                         # strictly hourly
  format(h$time[1]) == "2014-04-01 01:00:00", attr(h$time, "tzone") == TZ,
  sum(h$flag == "relabelled") == 4,
  at("2016-03-07 12:00")$central == 42, at("2016-04-04 00:00")$central == 53,
  at("2018-04-25 00:00")$central == 64, at("2018-08-16 03:00")$central == 61,
  at("2015-09-25 08:00")$central == 267
)
# a file with a real gap must be refused, never silently relabelled
tmp <- tempfile(fileext = ".csv")
writeLines(c("24hr_psi,north,south,east,west,central", "1/1/2020 1:00,1,1,1,1,1",
             "1/1/2020 2:00,1,1,1,1,1", "1/1/2020 4:00,1,1,1,1,1"), tmp)
stopifnot(inherits(try(read_hist(tmp), silent = TRUE), "try-error"))
cat("OK test_01a_hist\n")
