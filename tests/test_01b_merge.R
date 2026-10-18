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
# refresh rule: partial or missing files are fetched again; complete past files are not
d <- tempfile(); dir.create(d); j <- function(n) paste0('{"data":{"items":[', paste(rep('{"timestamp":"x"}', n), collapse = ","), ']}}')
writeLines(j(3), file.path(d, "a.json")); writeLines(j(24), file.path(d, "b.json"))
today <- as.Date("2026-11-01")
stopifnot(needs_fetch(file.path(d, "a.json"), as.Date("2026-10-18"), today),      # partial file
          !needs_fetch(file.path(d, "b.json"), as.Date("2026-10-17"), today),     # complete past day
          needs_fetch(file.path(d, "b.json"), today, today),                      # today may be partial
          needs_fetch(file.path(d, "none.json"), as.Date("2026-10-17"), today))   # missing file
cat("OK test_01b_merge\n")
