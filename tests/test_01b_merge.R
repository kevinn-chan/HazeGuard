# tests/test_01b_merge.R
source("R/00_fns_data.R")
x <- load_hourly()
q <- read.csv("outputs/00_data_quality.csv"); v <- setNames(q$value, q$name)
stopifnot(
  identical(names(x), c("time", REG, "natmax", "source", "flag")),
  !anyDuplicated(x$time), all(diff(as.numeric(x$time)) == 3600),    # no gaps, no doubles
  as.Date(format(max(x$time), "%Y-%m-%d")) >= as.Date("2026-10-17"),
  x$central[format(x$time, "%Y-%m-%d %H:%M") == "2026-10-09 23:00"] == 186,
  !anyNA(x[c(REG, "natmax")]), all(x$natmax == do.call(pmax, x[REG])),
  v[["overlap_mismatches"]] == 0, v[["relabelled_rows"]] == 4, v[["missing_hours"]] == 0
)
# gap rule: <= 3 missing hours interpolated and flagged; longer gaps stop the build
t0 <- as.POSIXct("2026-01-01 00:00", tz = TZ)
mk <- function(h) data.frame(time = t0 + 3600 * h, north = h * 10L, south = h * 10L, east = h * 10L,
                             west = h * 10L, central = h * 10L, source = "live", flag = "")
f <- fill_gaps(mk(c(0, 1, 4, 5)))
stopifnot(nrow(f) == 6, f$central[f$time == t0 + 7200] == 20, sum(f$flag == "interpolated") == 2)
stopifnot(inherits(try(fill_gaps(mk(c(0, 5))), silent = TRUE), "try-error"))
# coverage rule: data that stops short of the required end hour (a failed or partial last
# download) stops the build instead of passing as complete
end <- as.POSIXct("2026-10-31 23:00", tz = TZ)
short <- mk(0:3); short$time <- end - 3600 * (4:1)                 # ends 22:00
full <- mk(0:3); full$time <- end - 3600 * (3:0)                   # ends 23:00
stopifnot(inherits(try(check_coverage(short, end), silent = TRUE), "try-error"),
          isTRUE(check_coverage(full, end)))
# coverage policy: an offline rebuild (teammates, no --fetch) never stops on older data;
# a download must reach a day ago; after the freeze the data must reach DATA_END 23:00
now <- as.POSIXct("2026-10-20 15:30", tz = TZ)
stopifnot(is.na(coverage_target(fetch = FALSE, data_end = as.Date(NA), now = now)),
          coverage_target(fetch = TRUE, data_end = as.Date(NA), now = now) == as.POSIXct("2026-10-19 15:00", tz = TZ),
          coverage_target(fetch = FALSE, data_end = as.Date("2026-10-31"), now = now) ==
            as.POSIXct("2026-10-31 23:00", tz = TZ))
# refresh rule: partial or missing files are fetched again; complete past files are not
d <- tempfile(); dir.create(d); j <- function(n) paste0('{"data":{"items":[', paste(rep('{"timestamp":"x"}', n), collapse = ","), ']}}')
writeLines(j(3), file.path(d, "a.json")); writeLines(j(24), file.path(d, "b.json"))
today <- as.Date("2026-11-01")
stopifnot(needs_fetch(file.path(d, "a.json"), as.Date("2026-10-18"), today),      # partial file
          !needs_fetch(file.path(d, "b.json"), as.Date("2026-10-17"), today),     # complete past day
          needs_fetch(file.path(d, "b.json"), today, today),                      # today may be partial
          needs_fetch(file.path(d, "none.json"), as.Date("2026-10-17"), today))   # missing file
# "today" is Singapore's date whatever the laptop's time zone
stopifnot(today_sgt(as.POSIXct("2026-10-18 17:30", tz = "UTC")) == as.Date("2026-10-19"),
          today_sgt(as.POSIXct("2026-10-18 15:59", tz = "UTC")) == as.Date("2026-10-18"))
# downloads are checked before they replace a file
d <- tempfile(); dir.create(d)
writeLines('{"code":4,"errorMsg":"rate limited"}', bad <- file.path(d, "bad.json"))
writeLines("<html>busy</html>", page <- file.path(d, "page.csv"))
stopifnot(!live_ok(bad), !live_ok(file.path(d, "none.json")), live_ok("data/raw/live/2026-10-17.json"),
          !hist_ok(page), hist_ok("data/raw/psi_hist.csv"))
# data files are written with LF line endings on every computer (Windows text mode would add CR)
f <- tempfile(fileext = ".csv"); write_lf(data.frame(a = 1:2, b = c("x", "y")), f)
stopifnot(!any(readBin(f, "raw", file.size(f)) == as.raw(13)), identical(read.csv(f)$b, c("x", "y")))
cat("OK test_01b_merge\n")
