# tests/test_07_figures_m3.R
# 10 KB: real charts are 18 KB or more on every computer we use (Windows saves smaller PNGs than
# a Mac); a blank or error-only image is under 7 KB.
f <- "outputs/figures/fig5_prices.png"
stopifnot(file.exists(f), file.size(f) > 10000)
cat("OK test_07_figures_m3\n")
