# Shared chart style for every team chart (charts 1-5): one grey for the data,
# one accent for what the title is about, a dark grey for reference lines.
PAL <- c(data = "#9E9E9E", accent = "#1F6FB2", ref = "#424242")

# Usage: save_chart("outputs/figures/fig4_elnino.png", function() plot(...), "Title stating the finding")
save_chart <- function(file, draw, title, subtitle = NULL) {
  png(file, width = 1600, height = 900, res = 150)
  on.exit(dev.off())
  par(mar = c(4, 4.5, 4.5, 1), las = 1, bty = "l")
  draw()
  title(main = title, adj = 0, line = 2.2, font.main = 2)
  if (!is.null(subtitle)) mtext(subtitle, 3, adj = 0, line = 0.8, cex = 0.9, col = PAL["ref"])
  invisible(file)
}

# "18 Oct 2026" on every computer: the month comes from month.abb, never from the system language (%b)
fmt_date <- function(d) {
  sprintf("%d %s %d", as.integer(format(d, "%d")), month.abb[as.integer(format(d, "%m"))], as.integer(format(d, "%Y")))
}
