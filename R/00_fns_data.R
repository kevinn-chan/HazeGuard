# M1's data functions: read, repair, fetch, merge and fill PSI readings,
# then build the daily and season tables. Scripts 01 and 02 call these.
source("R/00_load.R")

# History CSV from data.gov.sg. The file holds exactly one row per hour, in
# order, but a few rows carry a wrong timestamp label (profiled 18 Oct: 4 rows).
# True times therefore come from row position; labels are only a cross-check.
read_hist <- function(path = "data/raw/psi_hist.csv") {
  h <- read.csv(path, check.names = FALSE, colClasses = "character")
  n <- nrow(h)
  lab <- as.POSIXct(h[[1]], format = "%d/%m/%Y %H:%M", tz = TZ)
  if (is.na(lab[1])) stop("first timestamp does not parse: ", h[[1]][1])
  time <- lab[1] + 3600 * (seq_len(n) - 1)
  if (!isTRUE(lab[n] == time[n]))
    stop(sprintf("last label %s is not %d hours after the first: the file has a real gap or an extra row",
                 h[[1]][n], n - 1))
  bad <- is.na(lab) | lab != time
  if (sum(bad) > 10) stop(sum(bad), " labels disagree with their position; refusing to relabel")
  message(sum(bad), " history rows relabelled from file position")
  data.frame(time = time, lapply(h[REG], as.integer), source = "hist",
             flag = ifelse(bad, "relabelled", ""), stringsAsFactors = FALSE)
}
