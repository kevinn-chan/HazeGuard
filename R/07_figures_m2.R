# Chart 4 (M2): each season's trigger rate against its El Nino reading.
# Writes outputs/figures/fig4_elnino.png. Uses the shared style in R/00_style.R.
source("R/00_load.R")
source("R/00_style.R")
s <- load_season()

# Your Task 3 numbers, for the title (never typed by hand)
k <- read.csv("outputs/03_inference.csv")
v <- setNames(k$value, k$name)

dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)

save_chart("outputs/figures/fig4_elnino.png", function() {
  plot(s$oni_jja, 100 * s$trigger_rate, pch = 16,
       col = ifelse(s$el_nino, PAL["accent"], PAL["data"]),
       ylim = c(0, 55),
       xlab = "NOAA El Nino index, Jun-Aug", ylab = "Sep-Oct days the refund triggers (%)")
  # Label only the El Nino seasons, so the labels don't pile up near zero
  text(s$oni_jja[s$el_nino], 100 * s$trigger_rate[s$el_nino], s$year[s$el_nino],
       pos = 3, cex = 0.8)
  abline(v = 0.5, lty = 2, col = PAL["ref"])   # El Nino threshold
}, sprintf("El Nino seasons triggered on %.0f%% of days; other seasons on %.1f%%",
           100 * v[["p_elnino"]], 100 * v[["p_normal"]]),
"One dot per season. Source: NEA via data.gov.sg; NOAA CPC.")
