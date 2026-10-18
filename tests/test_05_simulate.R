# tests/test_05_simulate.R
p <- read.csv("outputs/05_prices.csv", stringsAsFactors = FALSE); g <- function(s, col) p[p$scenario == s, col]
t3 <- read.csv("outputs/05_threeday.csv", stringsAsFactors = FALSE)
stopifnot(
  identical(sort(p$scenario), c("elnino", "mixture", "naive", "normal")),
  g("normal", "fair_price") < 2,
  g("elnino", "fair_price") > 25, g("elnino", "fair_price") < 42,
  abs(g("mixture", "mean_hits") - g("naive", "mean_hits")) < 0.2,   # same average...
  g("mixture", "safe95_price") >= 1.5 * g("naive", "safe95_price"), # ...much fatter tail
  t3$p_all3[t3$model == "markov"] > 10 * t3$p_all3[t3$model == "iid"]
)
cat("OK test_05_simulate\n")

