# Task 5 (M3): simulate 10,000 Sep-Oct seasons to price HazeGuard (a S$105 ticket refund).
# Writes outputs/05_prices.csv and outputs/05_threeday.csv.
# Steps and the test are in the Google Doc tab "M3: Pricing" (Task 5). Write the test first.
set.seed(1202)                                   # must stay the first line that runs
source("R/00_load.R")
N <- 10000; days <- 61; ev <- seq(7, 56, by = 7); price <- 105; p_season_elnino <- 3 / 13

# Start today with the 18 Oct snapshot values; once M2's outputs/03_inference.csv exists,
# the real numbers are used automatically.
snapshot <- c(p_all = 0.072, p_hh = 0.64, p_hc = 0.03, p_hh_elnino = 0.68, p_hc_elnino = 0.15,
              p_hh_normal = 0.20, p_hc_normal = 0.007)
v <- if (file.exists("outputs/03_inference.csv")) {
  k <- read.csv("outputs/03_inference.csv")
  setNames(k$value, k$name)
} else snapshot

# Hints (uncomment and complete):
# sim_season <- function(hh, hc, days = 61) {          # one season: TRUE = hazy morning
#   s <- logical(days)
#   s[1] <- runif(1) < hc / (1 - hh + hc)              # day 1 at the long-run haze rate
#   for (t in 2:days) s[t] <- runif(1) < if (s[t - 1]) hh else hc
#   s
# }
# stopifnot(all(sim_season(1, 1)), !any(sim_season(0, 0)))   # self-check
# hits <- function(regime_prob, n = N) ...              # events hit per season, El Nino with prob regime_prob
# normal <- hits(0); elnino <- hits(1); mixture <- hits(p_season_elnino); naive <- rbinom(N, length(ev), v[["p_all"]])
# per scenario: mean_hits, p_any, p_ge3, q95_hits = quantile(x, .95, type = 1),
#   fair_price = mean_hits * price / length(ev), safe95_price = q95_hits * price / length(ev)
# three-day event: markov = mean(replicate(N, all(sim_season(v[["p_hh"]], v[["p_hc"]], 3)))), iid = v[["p_all"]]^3
