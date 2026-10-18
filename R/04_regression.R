# Task 4 (M2): how much does El Nino raise Central's 8am PSI, controlling for the month?
# Writes outputs/04_regression.csv (columns model, term, estimate, std_error, p_value).
# Steps and the test are in the Google Doc tab "M2: Evidence" (Task 4). Write the test first.
source("R/00_load.R")
d <- load_daily()

# Hints (uncomment and complete):
# a <- d[d$month %in% 8:11 & !is.na(d$central8), ]                 # Aug-Nov; August is the baseline
# m_oni   <- lm(central8 ~ factor(month) + oni_jja, data = a)       # El Nino as a number
# m_dummy <- lm(central8 ~ factor(month) + el_nino, data = a)       # El Nino as yes/no (dummy coding)
# tidy <- function(m, name) {
#   k <- summary(m)$coefficients
#   data.frame(model = name, term = rownames(k), estimate = k[, 1], std_error = k[, 2], p_value = k[, 4])
# }
# Add a row term = "r_squared" per model (summary(m)$r.squared, other columns NA), and for m_oni the
# October predictions predict(m_oni, data.frame(month = 10, oni_jja = c(0, 1.8))) as terms
# "pred_oct_oni_0" and "pred_oct_oni_1.8".
# write.csv(rbind(tidy(m_oni, "oni"), tidy(m_dummy, "dummy"), ...), "outputs/04_regression.csv", row.names = FALSE)
