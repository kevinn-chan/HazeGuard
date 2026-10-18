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

# Freeze switch. Before the freeze the data runs up to today; afterwards it is
# fixed so every rerun gives identical numbers.
DATA_END <- as.Date(NA)   # set to as.Date("2026-10-31") at the 1 Nov freeze
data_end <- function() if (is.na(DATA_END)) Sys.Date() else DATA_END

HIST_URL <- "https://api-open.data.gov.sg/v1/public/api/datasets/d_b4cf557f8750260d229c49fd768e11ed/poll-download"
LIVE_URL <- "https://api-open.data.gov.sg/v2/real-time/api/psi?date="

# Download the history CSV once; the saved snapshot is reused unless refresh = TRUE.
fetch_hist <- function(dest = "data/raw/psi_hist.csv", refresh = FALSE) {
  if (file.exists(dest) && !refresh) return(invisible(dest))
  for (i in 1:5) {
    r <- jsonlite::fromJSON(HIST_URL)
    if (identical(r$data$status, "DOWNLOAD_SUCCESS")) break
    if (i == 5) stop("history download not ready after 5 tries: ", r$data$status)
    Sys.sleep(5)
  }
  part <- paste0(dest, ".part")                     # same folder, so the rename is atomic
  download.file(r$data$url, part, quiet = TRUE, mode = "wb")
  file.rename(part, dest)
  invisible(dest)
}

# A day's live file is fetched again if it is missing, unreadable, short of
# 24 hourly readings, or is today (still filling up).
needs_fetch <- function(path, date, today = Sys.Date()) {
  if (!file.exists(path) || date >= today) return(TRUE)
  n <- tryCatch(length(jsonlite::fromJSON(path)$data$items$timestamp), error = function(e) -1L)
  n < 24
}

fetch_live <- function(from = as.Date("2026-09-01"), to = data_end(), dir = "data/raw/live") {
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  skipped <- 0
  for (d in as.list(seq(from, to, by = "day"))) {
    path <- file.path(dir, paste0(format(d), ".json"))
    if (!needs_fetch(path, d)) { skipped <- skipped + 1; next }
    part <- paste0(path, ".part")
    ok <- FALSE
    for (attempt in 1:2) {
      ok <- tryCatch({ download.file(paste0(LIVE_URL, format(d)), part, quiet = TRUE); TRUE },
                     error = function(e) FALSE, warning = function(w) FALSE)
      if (ok) break
      Sys.sleep(10)
    }
    if (ok) {
      file.rename(part, path)
      message(format(d), " ok (", length(jsonlite::fromJSON(path)$data$items$timestamp), ")")
    } else {
      unlink(part)
      message(format(d), " FAIL")
    }
  }
  message(skipped, " complete days already saved, not re-downloaded")
  invisible(dir)
}

read_live <- function(dir = "data/raw/live") {
  files <- sort(list.files(dir, "^\\d{4}-\\d{2}-\\d{2}\\.json$", full.names = TRUE))
  x <- do.call(rbind, lapply(files, function(f) {
    it <- jsonlite::fromJSON(f)$data$items
    if (!length(it)) return(NULL)
    data.frame(time = as.POSIXct(substr(it$timestamp, 1, 19), format = "%Y-%m-%dT%H:%M:%S", tz = TZ),
               lapply(it$readings$psi_twenty_four_hourly[REG], as.integer),
               source = "live", flag = "", stringsAsFactors = FALSE)
  }))
  bad <- !complete.cases(x[c("time", REG)])
  if (any(bad)) message(sum(bad), " live rows with missing values dropped; the gap rule fills them")
  x <- x[!bad, ]
  x[order(x$time), ]
}

# History wins where both sources have the same hour; mismatches are counted.
merge_psi <- function(hist, live) {
  both <- live$time %in% hist$time
  a <- hist[match(live$time[both], hist$time), REG]
  b <- live[both, REG]
  x <- rbind(hist, live[!both, ])
  x <- x[order(x$time), ]
  rownames(x) <- NULL
  list(data = x, overlap_hours = sum(both), overlap_mismatches = sum(a != b))
}

# Fill runs of up to max_gap missing hours by straight-line interpolation and
# flag them; a longer run stops the build rather than inventing data.
fill_gaps <- function(x, max_gap = 3L) {
  x <- x[order(x$time), ]
  grid <- seq(min(x$time), max(x$time), by = "hour")
  miss <- grid[!grid %in% x$time]
  if (length(miss)) {
    run <- cumsum(c(TRUE, diff(as.numeric(miss)) != 3600))
    len <- tabulate(run)
    if (any(len > max_gap)) {
      k <- which.max(len)
      stop(sprintf("gap of %d hours from %s is longer than %d; refusing to interpolate",
                   len[k], format(miss[run == k][1], "%Y-%m-%d %H:%M"), max_gap))
    }
    add <- data.frame(time = miss,
                      lapply(setNames(REG, REG), function(r)
                        as.integer(round(approx(as.numeric(x$time), x[[r]], xout = as.numeric(miss))$y))),
                      source = "fill", flag = "interpolated", stringsAsFactors = FALSE)
    x <- rbind(x, add)
    x <- x[order(x$time), ]
  }
  rownames(x) <- NULL
  x
}
