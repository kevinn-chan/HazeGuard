# Task 4 (M2): how much does El Nino raise Central's 8am PSI, controlling for the month?
# Writes outputs/04_regression.csv (columns model, term, estimate, std_error, p_value).
source("R/00_load.R")
d <- load_daily()

# Data: Aug-Nov mornings with an 8am reading (should be 1,543). August is the baseline month.
a <- d[d$month %in% 8:11 & !is.na(d$central8), ]

# Two models: El Nino as a number (ONI index), and as yes/no
m_oni   <- lm(central8 ~ factor(month) + oni_jja, data = a)
m_dummy <- lm(central8 ~ factor(month) + el_nino, data = a)

# Turn a model's coefficient table into tidy rows
tidy <- function(m, name) {
  k <- summary(m)$coefficients
  data.frame(model = name, term = rownames(k), estimate = k[, 1],
             std_error = k[, 2], p_value = k[, 4], row.names = NULL)
}

# One extra row per model for R-squared
r2_row <- function(m, name) {
  data.frame(model = name, term = "r_squared", estimate = summary(m)$r.squared,
             std_error = NA, p_value = NA)
}

# October predictions from the ONI model: neutral year (0) and this year (1.8)
pr <- predict(m_oni, data.frame(month = 10, oni_jja = c(0, 1.8)))
pred_rows <- data.frame(model = "oni", term = c("pred_oct_oni_0", "pred_oct_oni_1.8"),
                        estimate = unname(pr), std_error = NA, p_value = NA)

# Combine and write
out <- rbind(tidy(m_oni, "oni"), r2_row(m_oni, "oni"), pred_rows,
             tidy(m_dummy, "dummy"), r2_row(m_dummy, "dummy"))
dir.create("outputs", showWarnings = FALSE)
write.csv(out, "outputs/04_regression.csv", row.names = FALSE)
