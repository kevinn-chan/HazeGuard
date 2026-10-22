# Task 6 (M3): does the price survive other trigger choices, and where does HazeShield leave a gap?
# Writes outputs/06_sensitivity.csv and outputs/06_hazeshield.csv.
# Steps and the test are in the Google Doc tab "M3: Pricing" (Task 6). Write the test first.
source("R/00_load.R")
d <- load_daily()
s <- load_season()

# Hints (uncomment and complete):
so <- d[d$in_season, ]
base          <- mean(so$trigger, na.rm = TRUE)                  # Central 08:00 above 100
threshold_150 <- mean(so$central8 > 150, na.rm = TRUE)
national_max  <- mean(so$natmax > 100)                           # worst region, any hour
e <- so[so$el_nino & !is.na(so$trigger), ]
elnino_drop_2015 <- mean(e$trigger[e$year != 2015])
elnino_drop_2023 <- mean(e$trigger[e$year != 2023])
elnino_drop_2026 <- mean(e$trigger[e$year != 2026])
p <- c(
  base              = base,
  threshold_150     = threshold_150,
  national_max      = national_max,
  elnino_drop_2015  = elnino_drop_2015,
  elnino_drop_2023  = elnino_drop_2023,
  elnino_drop_2026  = elnino_drop_2026
)
write.csv(
  data.frame(variant = names(p), p_trigger = p, fair_price = 105 * p),
  "outputs/06_sensitivity.csv",
  row.names = FALSE
)
HazeShield: bad days per season are already in s$bad_days
payout_pct <- c(0, 20, 40, 60, 80, 100)[findInterval(s$bad_days, c(0, 20, 25, 30, 35, 40))]
write.csv(
  data.frame(year = s$year, bad_days = s$bad_days, payout_pct = payout_pct),
  "outputs/06_hazeshield.csv",
  row.names = FALSE
)
