# tests/test_04_regression.R
r <- read.csv("outputs/04_regression.csv", stringsAsFactors = FALSE)
g <- function(m, t) r[r$model == m & r$term == t, ]
stopifnot(
  g("oni", "oni_jja")$estimate > 12, g("oni", "oni_jja")$estimate < 24, g("oni", "oni_jja")$p_value < 0.001,
  g("dummy", "el_ninoTRUE")$estimate > 15, g("dummy", "el_ninoTRUE")$p_value < 0.001,
  g("oni", "factor(month)10")$estimate > 0,
  g("oni", "r_squared")$estimate > g("dummy", "r_squared")$estimate,
  g("oni", "pred_oct_oni_1.8")$estimate > g("oni", "pred_oct_oni_0")$estimate
)
cat("OK test_04_regression\n")
