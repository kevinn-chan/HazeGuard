# tests/test_03_inference.R
k <- read.csv("outputs/03_inference.csv"); v <- setNames(k$value, k$name)
near <- function(x, target, tol) abs(x - target) <= tol
stopifnot(
  near(v[["p_all"]], 0.072, 0.015), near(v[["p_elnino"]], 0.30, 0.06), near(v[["p_normal"]], 0.008, 0.005),
  near(v[["p_hh"]], 0.64, 0.08), near(v[["p_hc"]], 0.03, 0.015),
  v[["ci_season_hi"]] - v[["ci_season_lo"]] > v[["ci_day_hi"]] - v[["ci_day_lo"]],  # seasons are the honest unit
  v[["ci_season_lo"]] >= 0,
  v[["p_value_elnino"]] < 1e-10,
  near(v[["fair_all"]], 105 * v[["p_all"]], 1e-9),
  near(v[["p_any8_iid"]], 1 - (1 - v[["p_all"]])^8, 1e-9)
)
cat("OK test_03_inference\n")

#run source("R/run_all.R") to check for ALL OK 
