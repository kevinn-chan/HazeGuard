# Build the gap-free hourly table and the data-quality report: Rscript R/01_fetch.R
source("R/00_fns_data.R")
fetch_hist()
fetch_live()
h <- read_hist()
l <- read_live()
m <- merge_psi(h, l)
x <- fill_gaps(m$data)
if (!is.na(DATA_END)) x <- x[x$time <= as.POSIXct(paste(DATA_END, "23:00"), tz = TZ), ]
x$natmax <- do.call(pmax, x[REG])
x <- x[c("time", REG, "natmax", "source", "flag")]

out <- x
out$time <- format(x$time, "%Y-%m-%d %H:%M")
write.csv(out, "data/psi_hourly.csv", row.names = FALSE)

grid <- seq(min(x$time), max(x$time), by = "hour")
q <- data.frame(
  name = c("hist_rows", "live_rows", "overlap_hours", "overlap_mismatches", "relabelled_rows",
           "interpolated_hours", "missing_hours", "total_hours", "first_time", "last_time"),
  value = c(nrow(h), nrow(l), m$overlap_hours, m$overlap_mismatches, sum(x$flag == "relabelled"),
            sum(x$flag == "interpolated"), sum(!grid %in% x$time), nrow(x),
            format(min(x$time), "%Y-%m-%d %H:%M"), format(max(x$time), "%Y-%m-%d %H:%M")))
dir.create("outputs", showWarnings = FALSE)
write.csv(q, "outputs/00_data_quality.csv", row.names = FALSE)
print(q, row.names = FALSE)
