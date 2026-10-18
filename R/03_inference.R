# Task 3 (M2): how often would the refund pay out, does haze persist, and does El Nino matter?
# Writes outputs/03_inference.csv with two columns, name and value. The exact names are in the
# Google Doc tab "M2: Evidence" (Task 3), and M3's simulation reads them, so spell them exactly.
# Before you write any code here: copy the Task 3 test from the Google Doc into
# tests/test_03_inference.R, run source("R/run_all.R"), and watch it fail.
source("R/00_load.R")
d <- load_daily()    # one row per day; see docs/data_dictionary.md
s <- load_season()   # one row per Sep-Oct season

# Hints, step by step (uncomment and complete):
# so <- d[d$in_season & !is.na(d$trigger), ]                 # Sep-Oct days with a known trigger
# p_all    <- mean(so$trigger)                                # Module 1: how often it pays out
# p_elnino <- mean(so$trigger[so$el_nino]);  p_normal <- mean(so$trigger[!so$el_nino])
#
# Persistence pairs (same rule as M1's chart 3): in-season days except 1 Sep, yesterday known
# pairs <- so[format(so$date, "%m-%d") != "09-01" & !is.na(so$trigger_prev), ]
# p_hh <- mean(pairs$trigger[pairs$trigger_prev])             # hazy today, given hazy yesterday
# p_hc <- mean(pairs$trigger[!pairs$trigger_prev])            # hazy today, given clear yesterday
# ...then the same two numbers for El Nino seasons and for normal seasons (pairs$el_nino)
#
# ci_day    <- prop.test(sum(so$trigger), nrow(so))$conf.int  # Module 2: days as the unit
# ci_season <- t.test(s$trigger_rate)$conf.int                # seasons as the unit; use max(0, lower)
# p_value_elnino <- prop.test(c(x_elnino, x_normal), c(n_elnino, n_normal))$p.value
# fair_all <- 105 * p_all  (and fair_elnino, fair_normal);  p_any8_iid <- 1 - (1 - p_all)^8
#
# out <- data.frame(name = c("n_days", "p_all", ...), value = c(nrow(so), p_all, ...))
# write.csv(out, "outputs/03_inference.csv", row.names = FALSE)
