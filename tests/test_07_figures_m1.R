# tests/test_07_figures_m1.R
f <- file.path("outputs/figures", c("fig1_timeline.png", "fig2_months.png", "fig3_persistence.png"))
n <- read.csv("outputs/m1_numbers.csv", stringsAsFactors = FALSE); v <- setNames(n$value, n$name)
num <- function(k) as.numeric(v[[k]])
stopifnot(all(file.exists(f)), all(file.size(f) > 20000),
          abs(num("sep_oct_share") - 89.8) < 3, num("bad_days_2015") == 46,
          abs(num("p_hh") - 0.64) < 0.08, abs(num("p_hc") - 0.03) < 0.015, num("relabelled_rows") == 4)
if (file.exists("outputs/03_inference.csv")) {          # chart 3 and M2 must agree exactly
  w <- read.csv("outputs/03_inference.csv"); w <- setNames(w$value, w$name)
  stopifnot(abs(num("p_hh") - w[["p_hh"]]) < 1e-9, abs(num("p_hc") - w[["p_hc"]]) < 1e-9)
}
# chart dates read the same on a computer set to another language
source("R/00_style.R")
old <- Sys.getlocale("LC_TIME"); suppressWarnings(Sys.setlocale("LC_TIME", "de_DE.UTF-8"))
x <- fmt_date(as.Date("2026-10-18")); Sys.setlocale("LC_TIME", old)
stopifnot(identical(x, "18 Oct 2026"))
cat("OK test_07_figures_m1\n")
