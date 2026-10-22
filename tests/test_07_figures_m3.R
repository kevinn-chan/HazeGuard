# tests/test_07_figures_m3.R
f <- "outputs/figures/fig5_prices.png"
stopifnot(file.exists(f), file.size(f) > 15000)
cat("OK test_07_figures_m3\n")
