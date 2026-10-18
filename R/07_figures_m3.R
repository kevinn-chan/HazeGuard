# Chart 5 (M3): fair and safe price per S$105 ticket, by scenario.
# Writes outputs/figures/fig5_prices.png. Uses the shared style in R/00_style.R.
source("R/00_load.R")
source("R/00_style.R")

# Hints (uncomment and complete, after R/05_simulate.R writes its file):
# p <- read.csv("outputs/05_prices.csv")
# save_chart("outputs/figures/fig5_prices.png", function() {
#   b <- barplot(t(as.matrix(p[c("fair_price", "safe95_price")])), beside = TRUE, names.arg = p$scenario,
#                col = c(PAL[["accent"]], PAL[["data"]]), border = NA, ylab = "S$ per ticket", ylim = c(0, 110))  # room for the S$105 line
#   abline(h = 105, lty = 2, col = PAL["ref"])                             # the ticket price
# }, sprintf("A haze refund costs about S$%.0f a ticket normally and S$%.0f in an El Nino year", ..., ...),
#    "Fair = expected payout; safe = covers 95% of simulated seasons. Seed 1202.")
