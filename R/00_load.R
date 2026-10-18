# Shared constants and typed loaders. Everyone sources this file:
#   source("R/00_load.R"); d <- load_daily()
TZ <- "Asia/Singapore"                               # every time in the project is SGT
REG <- c("north", "south", "east", "west", "central")
SEASON_MONTHS <- 9:10                                # Sep-Oct haze season
TRIGGER <- 100                                       # refund triggers when Central 08:00 PSI > 100
