# Chart 4 (M2): each season's trigger rate against its El Nino reading.
# Writes outputs/figures/fig4_elnino.png. Uses the shared style in R/00_style.R.
source("R/00_load.R")
source("R/00_style.R")
s <- load_season()

# Hints (uncomment and complete):
# save_chart("outputs/figures/fig4_elnino.png", function() {
#   plot(s$oni_jja, 100 * s$trigger_rate, pch = 16, col = ifelse(s$el_nino, PAL["accent"], PAL["data"]),
#        xlab = "NOAA El Nino index, Jun-Aug", ylab = "Sep-Oct days the refund triggers (%)")
#   text(s$oni_jja, 100 * s$trigger_rate, s$year, pos = 3, cex = 0.8)   # label each dot with its year
#   abline(v = 0.5, lty = 2, col = PAL["ref"])                            # El Nino threshold
# }, sprintf("El Nino seasons triggered on %.0f%% of days; other seasons on %.1f%%", ..., ...),
#    "One dot per season. Source: NEA via data.gov.sg; NOAA CPC.")
