source("R/00_load.R")
d <- load_daily()    # one row per day; see docs/data_dictionary.md
s <- load_season()   # one row per Sep-Oct season

# Sample: Sep-Oct days with a known trigger (should be 780)
so <- d[d$in_season & !is.na(d$trigger), ]

# Module 1: how often it pays out
p_all    <- mean(so$trigger)
p_elnino <- mean(so$trigger[so$el_nino])
p_normal <- mean(so$trigger[!so$el_nino])

# Persistence pairs (same rule as M1's chart 3): in-season days except 1 Sep, yesterday known (should be 767)
pairs <- so[format(so$date, "%m-%d") != "09-01" & !is.na(so$trigger_prev), ]
p_hh <- mean(pairs$trigger[pairs$trigger_prev])     # hazy today, given hazy yesterday
p_hc <- mean(pairs$trigger[!pairs$trigger_prev])    # hazy today, given clear yesterday

# Persistence by regime
p_hh_elnino <- mean(pairs$trigger[pairs$el_nino & pairs$trigger_prev])
p_hc_elnino <- mean(pairs$trigger[pairs$el_nino & !pairs$trigger_prev])
p_hh_normal <- mean(pairs$trigger[!pairs$el_nino & pairs$trigger_prev])
p_hc_normal <- mean(pairs$trigger[!pairs$el_nino & !pairs$trigger_prev])

# Module 2: confidence intervals
ci_day    <- prop.test(sum(so$trigger), nrow(so))$conf.int   # days as the unit
ci_season <- t.test(s$trigger_rate)$conf.int                 # seasons as the unit

# El Nino test: El Nino seasons against the others
x_elnino <- sum(so$trigger[so$el_nino]);  n_elnino <- sum(so$el_nino)
x_normal <- sum(so$trigger[!so$el_nino]); n_normal <- sum(!so$el_nino)
p_value_elnino <- prop.test(c(x_elnino, x_normal), c(n_elnino, n_normal))$p.value

# Prices: S$ per S$105 ticket
fair_all    <- 105 * p_all
fair_elnino <- 105 * p_elnino
fair_normal <- 105 * p_normal
p_any8_iid  <- 1 - (1 - p_all)^8   # chance at least one of 8 events pays, if days were independent

# Write all 19 rows (M3's code reads these names)
out <- data.frame(
  name = c("n_days", "p_all", "p_elnino", "p_normal", "p_hh", "p_hc",
           "p_hh_elnino", "p_hc_elnino", "p_hh_normal", "p_hc_normal",
           "ci_day_lo", "ci_day_hi", "ci_season_lo", "ci_season_hi",
           "p_value_elnino", "fair_all", "fair_elnino", "fair_normal", "p_any8_iid"),
  value = c(nrow(so), p_all, p_elnino, p_normal, p_hh, p_hc,
            p_hh_elnino, p_hc_elnino, p_hh_normal, p_hc_normal,
            ci_day[1], ci_day[2], max(0, ci_season[1]), ci_season[2],
            p_value_elnino, fair_all, fair_elnino, fair_normal, p_any8_iid)
)
write.csv(out, "outputs/03_inference.csv", row.names = FALSE)
