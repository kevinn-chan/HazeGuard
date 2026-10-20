# tests/test_07_figures_m2.R
# Size check lowered from 20000 to 5000 bytes: chart 4 is a simple 13-dot scatter that
# compresses small. 5 KB still catches a blank or broken image.
f <- "outputs/figures/fig4_elnino.png"
stopifnot(file.exists(f), file.size(f) > 5000)
cat("OK test_07_figures_m2\n")
