# tests/test_02_daily.R
source("R/00_load.R")
d <- load_daily(); s <- load_season()
k <- function(x) d[d$date == as.Date(x), ]
stopifnot(
  identical(names(d), c("date", "year", "month", "n_hours", "central8", "natmax", "trigger",
                        "trigger_prev", "in_season", "oni_jja", "el_nino")),
  inherits(d$date, "Date"), is.logical(d$trigger), is.logical(d$trigger_prev),
  d$date[1] == as.Date("2014-04-01"), k("2014-04-01")$n_hours == 23,               # SGT dates, not UTC
  all(d$n_hours[d$date > d$date[1] & d$date < max(d$date)] == 24),                  # no gaps
  identical(is.na(d$trigger), is.na(d$central8)),                                   # missing 08:00 => NA
  k("2015-09-25")$natmax == 322, k("2015-09-25")$central8 == 267, k("2026-10-16")$central8 == 226,
  isTRUE(k("2026-10-09")$trigger_prev), isFALSE(k("2026-10-02")$trigger_prev), is.na(d$trigger_prev[1]),
  sum(d$trigger[d$year == 2026 & d$in_season & d$date <= as.Date("2026-10-17")], na.rm = TRUE) == 23,
  identical(sort(unique(d$year[d$el_nino])), c(2015L, 2023L, 2026L)),
  abs(k("2026-10-01")$oni_jja - 1.80) < 0.15,                                       # NOAA revises slightly
  identical(names(s), c("year", "oni_jja", "el_nino", "days", "trigger_days", "trigger_rate",
                        "bad_days", "peak_natmax", "peak_date")),
  identical(s$year, 2014:2026), inherits(s$peak_date, "Date"),
  s$days[s$year == 2015] == 61, s$trigger_days[s$year == 2015] == 27, s$bad_days[s$year == 2015] == 46,
  s$peak_natmax[s$year == 2015] == 322, s$bad_days[s$year == 2026] >= 31
)
# an interpolated 08:00 hour is not a reading: the trigger is NA, never set by a filled-in value
source("R/00_fns_data.R")
h2 <- load_hourly(); h2$flag[format(h2$time, "%Y-%m-%d %H:%M") == "2026-10-10 08:00"] <- "interpolated"
k2 <- build_daily(h2, read_oni())[d$date == as.Date("2026-10-10"), ]
stopifnot(is.na(k2$central8), is.na(k2$trigger))
dict <- paste(readLines("docs/data_dictionary.md"), collapse = "\n")
cols <- unique(c(names(d), names(s), names(load_hourly())))
stopifnot(all(vapply(cols, function(n) grepl(paste0("`", n, "`"), dict, fixed = TRUE), logical(1))))
cat("OK test_02_daily\n")
