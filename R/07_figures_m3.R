# Chart 5 (M3): fair and safe price per S$105 ticket, by scenario.
# Writes outputs/figures/fig5_prices.png. Uses the shared style in R/00_style.R.
source("R/00_load.R")
source("R/00_style.R")

p <- read.csv("outputs/05_prices.csv")

# Map readable scenario names as requested
scenario_labels <- c(
  "normal"  = "Normal year",
  "elnino"  = "El Nino year",
  "mixture" = "Mixture",
  "naive"   = "All years alike"
)
p$pretty_name <- scenario_labels[p$scenario]

save_chart("outputs/figures/fig5_prices.png", function() {
  # Create the bar plot
  mat <- t(as.matrix(p[, c("fair_price", "safe95_price")]))
  b <- barplot(mat, beside = TRUE, names.arg = p$pretty_name,
               col = c(PAL[["accent"]], PAL[["data"]]), border = NA, 
               ylab = "S$ per ticket", ylim = c(0, 115)) 
  
  # Add dashed line for ticket price with text label
  abline(h = 105, lty = 2, col = PAL[["ref"]])
  text(x = mean(b), y = 108, labels = "S$105 ticket price", col = PAL[["ref"]], cex = 0.9)
  
  # Add legend, below the S$105 line so the two do not overlap
  legend(x = par("usr")[1], y = 100, legend = c("Fair price", "Safe price (95%)"), 
         fill = c(PAL[["accent"]], PAL[["data"]]), bty = "n", border = NA)
  
  # Add values on top of each bar
  text(x = b, y = mat + 3, labels = sprintf("S$%.0f", mat), cex = 0.8)
  
}, sprintf("A haze refund costs about S$%.0f a ticket normally and S$%.0f in an El Nino year", 
           p$fair_price[p$scenario == "normal"], 
           p$fair_price[p$scenario == "elnino"]),
"Fair = expected payout; safe = covers 95% of simulated seasons. Seed 1202.")