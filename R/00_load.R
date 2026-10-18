# Shared constants and typed loaders. Everyone sources this file:
#   source("R/00_load.R"); d <- load_daily()
TZ <- "Asia/Singapore"                               # every time in the project is SGT
REG <- c("north", "south", "east", "west", "central")
SEASON_MONTHS <- 9:10                                # Sep-Oct haze season
TRIGGER <- 100                                       # refund triggers when Central 08:00 PSI > 100

load_hourly <- function(path = "data/psi_hourly.csv") {
  x <- read.csv(path, colClasses = c(time = "character", source = "character", flag = "character"))
  x$time <- as.POSIXct(x$time, format = "%Y-%m-%d %H:%M", tz = TZ)
  x
}

load_daily <- function(path = "data/psi_daily.csv") {
  d <- read.csv(path)
  d$date <- as.Date(d$date)
  d
}

load_season <- function(path = "data/psi_season.csv") {
  s <- read.csv(path)
  s$peak_date <- as.Date(s$peak_date)
  s
}
