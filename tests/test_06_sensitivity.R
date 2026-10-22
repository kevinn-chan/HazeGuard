# tests/test_06_sensitivity.R
s <- read.csv("outputs/06_sensitivity.csv", stringsAsFactors = FALSE)
h <- read.csv("outputs/06_hazeshield.csv"); pay <- setNames(h$payout_pct, h$year)
stopifnot(
  identical(s$variant, c("base", "threshold_150", "national_max", "elnino_drop_2015", "elnino_drop_2023", "elnino_drop_2026")),
  s$p_trigger[s$variant == "threshold_150"] < s$p_trigger[s$variant == "base"],
  s$p_trigger[s$variant == "national_max"] > s$p_trigger[s$variant == "base"],
  pay[["2015"]] == 100, pay[["2026"]] >= 60,
  all(pay[!names(pay) %in% c("2015", "2026")] == 0)
)
cat("OK test_06_sensitivity\n")
