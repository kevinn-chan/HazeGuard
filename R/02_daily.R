# Build the daily and season tables: Rscript R/02_daily.R
source("R/00_fns_data.R")
if (!file.exists("data/raw/oni.txt")) download.file(ONI_URL, "data/raw/oni.txt", quiet = TRUE)
d <- build_daily(load_hourly(), read_oni())
s <- build_season(d)
write.csv(d, "data/psi_daily.csv", row.names = FALSE)
write.csv(s, "data/psi_season.csv", row.names = FALSE)
message(nrow(d), " days and ", nrow(s), " seasons written")
