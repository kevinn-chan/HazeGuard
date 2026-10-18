# Task 6 (M3): does the price survive other trigger choices, and where does HazeShield leave a gap?
# Writes outputs/06_sensitivity.csv and outputs/06_hazeshield.csv.
# Steps and the test are in the Google Doc tab "M3: Pricing" (Task 6). Write the test first.
source("R/00_load.R")
d <- load_daily()
s <- load_season()

# Hints (uncomment and complete):
# so <- d[d$in_season, ]
# base          <- mean(so$trigger, na.rm = TRUE)                  # Central 08:00 above 100
# threshold_150 <- mean(so$central8 > 150, na.rm = TRUE)
# national_max  <- mean(so$natmax > 100)                           # worst region, any hour
# elnino_drop_Y <- trigger rate over El Nino seasons without year Y, for Y = 2015, 2023, 2026
# fair_price = 105 * p_trigger, one row per variant, in that order
# HazeShield: bad days per season are already in s$bad_days
# payout_pct <- c(0, 20, 40, 60, 80, 100)[findInterval(s$bad_days, c(0, 20, 25, 30, 35, 40))]
