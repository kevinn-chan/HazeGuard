# Charts 1-3 and the numbers M1 presents: Rscript R/07_figures_m1.R
source("R/00_load.R")
source("R/00_style.R")
h <- load_hourly()
d <- load_daily()
s <- load_season()
dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)
src <- function(what) sprintf("%s. Source: NEA via data.gov.sg, to %s.", what, fmt_date(max(d$date)))
years <- sprintf("%d-%d", min(d$year), max(d$year))

haze <- d$natmax > 100                                   # a haze day: any region-hour above 100
share <- 100 * sum(haze & d$in_season) / sum(haze)
# persistence pairs: in-season days except 1 Sep, with both triggers known (data dictionary)
pairs <- d[d$in_season & format(d$date, "%m-%d") != "09-01" & !is.na(d$trigger) & !is.na(d$trigger_prev), ]
p_hh <- mean(pairs$trigger[pairs$trigger_prev])
p_hc <- mean(pairs$trigger[!pairs$trigger_prev])
bad <- setNames(s$bad_days, s$year)
others <- max(bad[!names(bad) %in% c("2015", "2026")])
s26 <- s[s$year == 2026, ]

save_chart("outputs/figures/fig1_timeline.png", function() {
  plot(d$date, d$natmax, type = "l", col = PAL["data"], lwd = 0.6, xlab = "",
       ylab = "Highest 24-hr PSI of the day", ylim = c(0, max(d$natmax) * 1.05))
  points(d$date[haze], d$natmax[haze], pch = 16, cex = 0.45, col = PAL["accent"])
  abline(h = 100, lty = 2, col = PAL["ref"])
  calm <- rle(haze)                                    # label sits mid-way along the longest haze-free run
  k <- which.max(ifelse(calm$values, 0, calm$lengths))
  mid <- cumsum(calm$lengths)[k] - calm$lengths[k] %/% 2
  text(d$date[mid], 100, "Unhealthy (101+)", adj = c(0.5, -0.5), col = PAL["ref"], cex = 0.85)
}, sprintf("2015 and 2026 stand apart: %d and %d haze days in Sep-Oct; no other year topped %d",
           bad[["2015"]], bad[["2026"]], others),
   src("Highest 24-hour PSI across the five regions each day; days above 100 in blue"))

m <- tabulate(d$month[haze], 12)
save_chart("outputs/figures/fig2_months.png", function() {
  b <- barplot(m, names.arg = month.abb, border = NA, ylim = c(0, max(m) * 1.15),
               col = ifelse(seq_len(12) %in% SEASON_MONTHS, PAL["accent"], PAL["data"]),
               ylab = sprintf("Haze days, %s", years))
  text(b, m, m, pos = 3, cex = 0.85, col = PAL["ref"])
}, sprintf("%d%% of haze days since 2014 fell in September or October", round(share)),
   src("Days when any region's 24-hour PSI went above 100, by calendar month"))

pc <- 100 * c(p_hh, p_hc)
save_chart("outputs/figures/fig3_persistence.png", function() {
  b <- barplot(pc, names.arg = c("After a hazy morning", "After a clear morning"), border = NA,
               col = c(PAL[["accent"]], PAL[["data"]]), ylim = c(0, 100), space = 0.8,
               ylab = "Chance the next morning is hazy (%)")
  text(b, pc, sprintf("%.0f%%", pc), pos = 3, font = 2, col = PAL["ref"])
}, sprintf("A hazy morning is followed by another %d%% of the time; a clear one, %d%%", round(pc[1]), round(pc[2])),
   src(sprintf("Hazy = Central 24-hr PSI above 100 at 08:00; Sep-Oct %s, %d day pairs", years, nrow(pairs))))

numbers <- data.frame(
  name = c("hours_total", "relabelled_rows", "haze_days_all", "haze_days_sep_oct", "sep_oct_share",
           "bad_days_2015", "bad_days_2026", "peak_2026", "peak_2026_date", "p_hh", "p_hc", "n_pairs"),
  value = c(nrow(h), sum(h$flag == "relabelled"), sum(haze), sum(haze & d$in_season), round(share, 1),
            bad[["2015"]], bad[["2026"]], s26$peak_natmax, format(s26$peak_date), p_hh, p_hc, nrow(pairs)))
write.csv(numbers, "outputs/m1_numbers.csv", row.names = FALSE)
print(numbers, row.names = FALSE)
