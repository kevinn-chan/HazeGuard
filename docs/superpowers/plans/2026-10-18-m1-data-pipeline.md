# M1 Data, Charts and Submission Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the team one gap-free, typed and documented haze dataset (hourly, daily and per-season), charts 1–3 with a shared chart style, a reproducible number freeze on 1 Nov, M1's video segment and the Word submission.

**Architecture:** Pure functions live in `R/00_fns_data.R`. Two thin scripts call them: `R/01_fetch.R` writes the hourly table and a data-quality report, and `R/02_daily.R` writes the daily and season tables. `R/00_load.R` holds the shared constants and typed loaders that M2–M4 use instead of `read.csv`, and `R/00_style.R` holds the chart style everyone shares. Every script has a `stopifnot()` test in `tests/`. `Rscript R/run_all.R` rebuilds everything and ends with `ALL OK`.

**Tech Stack:** R 4.5.2 (installed), base R graphics, `jsonlite` (installed). No other packages.

**Spec:** Course outline Appendix 2 (`~/Downloads/AB1202 Statistics and Analysis Semester 1 AY 2026-27 - Course Outline(1).pdf`), team plan `docs/superpowers/plans/2026-10-18-price-the-haze.md`, and the Haze Plan tab of the team Google Doc (four-way split). This plan replaces the team plan's Tasks 0, 1, 2 and 10 and M1's part of Task 7 wherever they differ.

## What M1 hands to the team

| Deliverable | Due | Used by |
| --- | --- | --- |
| `data/psi_hourly.csv`: every hour, 1 Apr 2014 01:00 to the data end, no gaps | Fri 23 Oct | Charts, checks |
| `data/psi_daily.csv`: one row per day, with trigger, previous-day trigger and El Niño flag | Fri 23 Oct | M2 (Tasks 3–4), M3 (Task 6) |
| `data/psi_season.csv`: one row per year for Sep–Oct (trigger days, bad days, peak) | Fri 23 Oct | M2 (season CI, chart 4), M3 (regime share, HazeShield) |
| `R/00_load.R`: `load_hourly()`, `load_daily()`, `load_season()` returning correct types | Fri 23 Oct | Everyone |
| `docs/data_dictionary.md`: every column, rule and known fix | Fri 23 Oct | Everyone, plus the video's "limits" line |
| `R/00_style.R`: shared colours and `save_chart()` | Fri 23 Oct | M2 (chart 4), M3 (chart 5) |
| `outputs/00_data_quality.csv`: hours, fixes, overlap check, gaps | Fri 23 Oct | M4 (script), M1 (S2) |
| Charts 1–3 and `outputs/m1_numbers.csv` | Thu 29 Oct | M4 (S1 uses chart 1), M1 (S2) |
| Number freeze (data cut at 31 Oct) | Sun 1 Nov | Everyone |
| Word file, submitted | Sat 14 Nov, 8pm | Course |

## What the data actually looks like (profiled 18 Oct)

- **History file (data.gov.sg):** 108,864 rows covering 108,864 hours (1 Apr 2014 01:00 to 1 Sep 2026 00:00). That is exactly one row per hour, with **no missing hours and no missing values**. Values range from 5 to 322.
- **Four mislabelled rows.** Their position in the file is right but their timestamp label is wrong. Dropping them would create gaps, and keeping their labels would create duplicates:

  | Row | Label in file | True time (from position) | Central |
  | --- | --- | --- | --- |
  | 16,956 | `7/3/2016 0:00` | 2016-03-07 12:00 | 42 |
  | 17,616 | `2016-04-04 010:00:00` (different format) | 2016-04-04 00:00 | 53 |
  | 35,640 | `24/4/2018 0:00` | 2018-04-25 00:00 | 64 |
  | 38,355 | `16/8/2018 2:00` | 2018-08-16 03:00 | 61 |
- **Live API:** 48 files covering 1 Sep to 18 Oct 2026. Every full day has 24 readings, and 18 Oct is partial (3 readings). Readings are posted about 45 minutes after the hour. The one hour shared with the history file (1 Sep 00:00) matches exactly.
- **Merged result:** 109,994 hours with 0 missing. Every day from 2 Apr 2014 to 17 Oct 2026 has 24 readings; 1 Apr 2014 has 23 because the file starts at 01:00.
- **ONI file (NOAA):** whitespace table `SEAS YR TOTAL ANOM`, with a `JJA` row for every year 1950–2026 (2026 = +1.80).
- **A bug in the team plan.** The team plan's refresh rule ("skip a date if its file exists and it is 2+ days old") would never re-download 18 Oct, which has only 3 readings. This plan re-downloads any file with fewer than 24 readings.

## Data contract (what downstream can rely on)

All times are Singapore time (SGT). The date of an hourly row is its calendar date in SGT; the 00:00 reading belongs to the day it is stamped with.

**`data/psi_hourly.csv`**: `time` (`"YYYY-MM-DD HH:MM"`), `north`, `south`, `east`, `west`, `central` (integer 24-hr PSI), `natmax` (integer, max of the five regions), `source` (`hist`, `live` or `fill`), `flag` (`""`, `relabelled` or `interpolated`).

**`data/psi_daily.csv`**: `date` (`"YYYY-MM-DD"`), `year`, `month`, `n_hours` (readings that day), `central8` (Central at 08:00, NA if absent), `natmax` (highest region-hour that day), `trigger` (`central8 > 100`, NA when `central8` is NA), `trigger_prev` (the previous calendar day's `trigger`, NA if unknown), `in_season` (month is 9 or 10), `oni_jja` (NOAA June–August anomaly for that year), `el_nino` (`oni_jja >= 0.5`).

These keep every column the team plan's Task 2 promised, with the same names. The extra columns are `n_hours`, `trigger_prev` and `in_season`.

**`data/psi_season.csv`** (Sep–Oct of each year, 2014–2026): `year`, `oni_jja`, `el_nino`, `days` (Sep–Oct days with a non-NA trigger), `trigger_days`, `trigger_rate` (= `trigger_days / days`), `bad_days` (Sep–Oct days with `natmax > 100`), `peak_natmax`, `peak_date`.

**Persistence rule (shared with M2):** p(haze | hazy yesterday) and p(haze | clear yesterday) use days with `in_season` that are not 1 September and have non-NA `trigger` and `trigger_prev`. As of 18 Oct this gives 766 pairs, p_hh = 0.6364 and p_hc = 0.0295.

## Global Constraints

- "Please only use freely available data and do not pay for data."
- "present a statistical analysis of the problem using R"
- "Record video at normal speed." "Every group member must show his/her face and participate in the presentation."
- Submission: "MS Word file and must follow the template"; name "AB1202AY2526S1-T_X-Grp_Y.docx"; "single spacing; one-inch margins on all sides"; "An executive summary of the presentation (max 400 words)"; "References (to data sources, articles, and AI tools used)".
- "This assignment is due by Week 13, Sunday, Nov 15, 2026 at/before 1:00 pm. Late submissions will be penalized: -15% for 0-3 hrs, -50% for 3-24 hrs, and -100% >24 hrs."
- Team rules:
  - Base R plus `jsonlite` only.
  - Run everything from the project root with `Rscript R/run_all.R`.
  - Every time is SGT (`tz = "Asia/Singapore"`).
  - Never derive a date with `as.Date(<POSIXct>)` without `tz`.

## Review Focus

1. **Mislabelled history rows.** The four rows above must keep their data under the corrected time: no hour dropped, no hour doubled. Pinned in the Task 1 test (exact Central values at the four corrected times, 108,864 strictly hourly rows).
2. **UTC date shift.** `as.Date()` on an SGT time defaults to UTC and moves 00:00–07:59 readings to the previous day (`2014-04-01 01:00` becomes `2014-03-31`). Pinned in the Task 3 test (first date is 2014-04-01 with 23 hours; Central at 08:00 on 2026-10-16 is 226).
3. **Partial days that never refresh.** A live file with fewer than 24 readings must be fetched again, and missing hours must not pass silently. Pinned in the Task 2 tests (`needs_fetch()` cases; gaps of 3 hours or less are interpolated and flagged, longer gaps stop the build) and the Task 3 test (every day except the first and last has 24 readings).
4. **Numbers drifting after the freeze.** Re-running after 1 Nov must give identical numbers. Pinned in Task 5 Step 3 (`DATA_END` set, so the last hour is 2026-10-31 23:00).
5. **One statistic, two answers.** Chart 3 and M2 must report the same p_hh and p_hc. Pinned in the Task 4 test (equal to 1e-9 when M2's file exists).

## File structure

```
R/run_all.R            sources R/0[1-7]_*.R in order, then tests/test_*.R; prints "ALL OK"
R/00_load.R            constants (TZ, REG, SEASON_MONTHS, TRIGGER) + typed loaders for everyone
R/00_fns_data.R        M1's pure functions: fetch, read, repair, merge, fill, daily, season
R/00_style.R           shared chart colours + save_chart()
R/01_fetch.R           writes data/psi_hourly.csv and outputs/00_data_quality.csv
R/02_daily.R           writes data/psi_daily.csv and data/psi_season.csv
R/07_figures_m1.R      charts 1-3 + outputs/m1_numbers.csv (M2 and M3 add 07_figures_m2.R / _m3.R)
tests/test_01a_hist.R  tests/test_01b_merge.R  tests/test_02_daily.R  tests/test_07_figures_m1.R
docs/data_dictionary.md
data/raw/              psi_hist.csv, live/YYYY-MM-DD.json, oni.txt (18 Oct snapshot already saved)
```

`00_*.R` files are helpers that other scripts `source()`; the runner skips them. Each chart owner keeps their own figures file so nobody edits the same file. This refines the team doc's single `R/07_figures.R`.

## M1 schedule

| When | Work |
| --- | --- |
| Sun 18 – Mon 19 Oct | Task 0, Task 1 |
| Tue 20 – Wed 21 Oct | Task 2 |
| Thu 22 Oct | Task 3, plus the references draft (Task 7 Step 1) |
| Fri 23 Oct | Hand-off to the team (Task 5 Step 1); M2 reviews your tests |
| Sat 24 – Thu 29 Oct | Task 4 (charts 1–3) |
| Fri 30 – Sat 31 Oct | Review M3's simulation (Task 5 Step 2) |
| Sun 1 Nov | Freeze (Task 5 Step 3) |
| Mon 2 – Wed 4 Nov | Task 6: rewrite your S2 lines from M4's draft |
| Thu 5 – Sun 8 Nov | Record S2 with the team |
| Mon 9 – Tue 10 Nov | Nothing (Quiz 2) |
| Wed 11 – Sat 14 Nov | Task 7: Word file, submit by 8pm Saturday |

---

### Task 0: Project skeleton and runner

**Files:**
- Create: `R/run_all.R`, `R/00_load.R` (constants only for now)

**Interfaces:**
- Produces:
  - `R/00_load.R` defines `TZ <- "Asia/Singapore"`, `REG <- c("north","south","east","west","central")`, `SEASON_MONTHS <- 9:10` and `TRIGGER <- 100`.
  - `Rscript R/run_all.R` sources every `R/0[1-7]_*.R` in name order (each with `local = new.env()`), then every `tests/test_*.R`, then prints `ALL OK`.

- [ ] **Step 1: Create the folders and init git.**

Run: `cd ~/AB1202-haze && mkdir -p R tests outputs/figures docs && git init`
Expected: `Initialized empty Git repository`

- [ ] **Step 2: Write `R/00_load.R` (the four constants) and `R/run_all.R`** (about 5 lines; pattern `"^0[1-7]_.*\\.R$"`).

- [ ] **Step 3: Run it with no scripts yet.**

Run: `Rscript R/run_all.R`
Expected: `ALL OK`

- [ ] **Step 4: Commit.**

```bash
git add -A && git commit -m "chore: skeleton, constants, runner, 18 Oct raw snapshot"
```

### Task 1: Repair the history file

**Files:**
- Create: `R/00_fns_data.R`
- Test: `tests/test_01a_hist.R`

**Interfaces:**
- Consumes: constants from `R/00_load.R`. `R/00_fns_data.R` starts with `source("R/00_load.R")`.
- Produces: `read_hist(path = "data/raw/psi_hist.csv") -> data.frame(time POSIXct[tz = TZ], north, south, east, west, central integer, source = "hist", flag character)`.

- [ ] **Step 1: Write the failing test.**

```r
# tests/test_01a_hist.R
source("R/00_fns_data.R")
h <- read_hist("data/raw/psi_hist.csv")
at <- function(t) h[format(h$time, "%Y-%m-%d %H:%M") == t, ]
stopifnot(
  nrow(h) == 108864, !anyDuplicated(h$time),
  all(diff(as.numeric(h$time)) == 3600),                         # strictly hourly
  format(h$time[1]) == "2014-04-01 01:00:00", attr(h$time, "tzone") == TZ,
  sum(h$flag == "relabelled") == 4,
  at("2016-03-07 12:00")$central == 42, at("2016-04-04 00:00")$central == 53,
  at("2018-04-25 00:00")$central == 64, at("2018-08-16 03:00")$central == 61,
  at("2015-09-25 08:00")$central == 267
)
# a file with a real gap must be refused, never silently relabelled
tmp <- tempfile(fileext = ".csv")
writeLines(c("24hr_psi,north,south,east,west,central", "1/1/2020 1:00,1,1,1,1,1",
             "1/1/2020 2:00,1,1,1,1,1", "1/1/2020 4:00,1,1,1,1,1"), tmp)
stopifnot(inherits(try(read_hist(tmp), silent = TRUE), "try-error"))
cat("OK test_01a_hist\n")
```

- [ ] **Step 2: Run it to verify it fails.**

Run: `Rscript tests/test_01a_hist.R`
Expected: FAIL with `cannot open file 'R/00_fns_data.R'`

- [ ] **Step 3: Implement `read_hist()` in `R/00_fns_data.R`.**

Read with `colClasses = "character"` and parse labels with `format = "%d/%m/%Y %H:%M", tz = TZ`. The true time of row i is the first label + (i − 1) hours. Then:
- `stop()` if the first label doesn't parse.
- `stop()` if the last label isn't exactly first + (n − 1) hours, because that means a real gap or extra row.
- `stop()` if more than 10 labels disagree with their position.
- Otherwise use the positional time, set `flag = "relabelled"` where the label disagreed, and `message()` the count.

- [ ] **Step 4: Run the test to verify it passes.**

Run: `Rscript tests/test_01a_hist.R`
Expected: `4 history rows relabelled from file position`, then `OK test_01a_hist`

- [ ] **Step 5: Commit.**

```bash
git add R/00_fns_data.R tests/test_01a_hist.R && git commit -m "feat: read history file and repair 4 mislabelled hours"
```

### Task 2: Live data, merge and gap guard

**Files:**
- Modify: `R/00_fns_data.R` (add functions)
- Create: `R/01_fetch.R`
- Test: `tests/test_01b_merge.R`

**Interfaces:**
- Consumes: `read_hist()` (Task 1).
- Produces (in `R/00_fns_data.R`):
  - `DATA_END <- as.Date(NA)`, with the comment `# set to as.Date("2026-10-31") at the 1 Nov freeze`.
  - `data_end() -> Date`: `DATA_END` if set, else `Sys.Date()`.
  - `fetch_hist(dest = "data/raw/psi_hist.csv", refresh = FALSE)`: skip if the file exists. Otherwise call the poll-download endpoint `https://api-open.data.gov.sg/v1/public/api/datasets/d_b4cf557f8750260d229c49fd768e11ed/poll-download`; if `data$status != "DOWNLOAD_SUCCESS"`, wait 5 s and retry up to 5 times; then download `data$url`.
  - `needs_fetch(path, date, today = Sys.Date()) -> logical`: TRUE if the file is missing, `date >= today` (that day may still be partial), the JSON fails to parse, or it holds fewer than 24 items.
  - `fetch_live(from = as.Date("2026-09-01"), to = data_end(), dir = "data/raw/live")`:
    - For each date from `from` to `to` where `needs_fetch()` is TRUE, request `https://api-open.data.gov.sg/v2/real-time/api/psi?date=YYYY-MM-DD` into a temp file and `file.rename()` it into place, so a failed download never leaves a half file.
    - On error, wait 10 s and retry once.
    - `message()` one line per date (`2026-10-09 ok (24)` or `FAIL`).
  - `read_live(dir) -> data.frame` (same columns as `read_hist()`, `source = "live"`, `flag = ""`). Time comes from `substr(timestamp, 1, 19)` with `format = "%Y-%m-%dT%H:%M:%S", tz = TZ`. Rows with any NA region are dropped with a message, so the gap rule handles them.
  - `merge_psi(hist, live) -> list(data, overlap_hours, overlap_mismatches)`: history wins where both sources have an hour; mismatches count region values that differ.
  - `fill_gaps(x, max_gap = 3L) -> data.frame`:
    - Build the complete hourly grid.
    - Interpolate each region linearly (`approx()`, rounded to integer) for runs of `max_gap` hours or fewer, with `source = "fill"` and `flag = "interpolated"`.
    - `stop()` naming the start and length of any longer run.
- `R/01_fetch.R`:
  - `fetch_hist()` and `fetch_live()`, then read, merge and fill.
  - Cut at `data_end()` 23:00 when `DATA_END` is set.
  - Add `natmax <- do.call(pmax, x[REG])`.
  - Write `data/psi_hourly.csv`, with `time` written as `format(time, "%Y-%m-%d %H:%M")`.
  - Write `outputs/00_data_quality.csv` (`name,value`) with names `hist_rows`, `live_rows`, `overlap_hours`, `overlap_mismatches`, `relabelled_rows`, `interpolated_hours`, `missing_hours`, `total_hours`, `first_time` and `last_time`.
- Add `load_hourly()` to `R/00_load.R`: it reads the CSV and converts `time` with `as.POSIXct(format = "%Y-%m-%d %H:%M", tz = TZ)`.

- [ ] **Step 1: Write the failing test.**

```r
# tests/test_01b_merge.R
source("R/00_fns_data.R")
x <- load_hourly()
q <- read.csv("outputs/00_data_quality.csv"); v <- setNames(q$value, q$name)
stopifnot(
  identical(names(x), c("time", REG, "natmax", "source", "flag")),
  !anyDuplicated(x$time), all(diff(as.numeric(x$time)) == 3600),    # no gaps, no doubles
  as.Date(format(max(x$time), "%Y-%m-%d")) >= as.Date("2026-10-17"),
  x$central[format(x$time, "%Y-%m-%d %H:%M") == "2026-10-09 23:00"] == 186,
  !anyNA(x[c(REG, "natmax")]), all(x$natmax == do.call(pmax, x[REG])),
  v[["overlap_mismatches"]] == 0, v[["relabelled_rows"]] == 4, v[["missing_hours"]] == 0
)
# gap rule: <= 3 missing hours interpolated and flagged; longer gaps stop the build
t0 <- as.POSIXct("2026-01-01 00:00", tz = TZ)
mk <- function(h) data.frame(time = t0 + 3600 * h, north = h * 10L, south = h * 10L, east = h * 10L,
                             west = h * 10L, central = h * 10L, source = "live", flag = "")
f <- fill_gaps(mk(c(0, 1, 4, 5)))
stopifnot(nrow(f) == 6, f$central[f$time == t0 + 7200] == 20, sum(f$flag == "interpolated") == 2)
stopifnot(inherits(try(fill_gaps(mk(c(0, 5))), silent = TRUE), "try-error"))
# refresh rule: partial or missing files are fetched again; complete past files are not
d <- tempfile(); dir.create(d); j <- function(n) paste0('{"data":{"items":[', paste(rep('{"timestamp":"x"}', n), collapse = ","), ']}}')
writeLines(j(3), file.path(d, "a.json")); writeLines(j(24), file.path(d, "b.json"))
today <- as.Date("2026-11-01")
stopifnot(needs_fetch(file.path(d, "a.json"), as.Date("2026-10-18"), today),      # partial file
          !needs_fetch(file.path(d, "b.json"), as.Date("2026-10-17"), today),     # complete past day
          needs_fetch(file.path(d, "b.json"), today, today),                      # today may be partial
          needs_fetch(file.path(d, "none.json"), as.Date("2026-10-17"), today))   # missing file
cat("OK test_01b_merge\n")
```

- [ ] **Step 2: Run it to verify it fails.**

Run: `Rscript tests/test_01b_merge.R`
Expected: FAIL with `could not find function "load_hourly"`

- [ ] **Step 3: Implement the functions and `R/01_fetch.R` above.**

- [ ] **Step 4: Run the build and the test.**

Run: `Rscript R/01_fetch.R && Rscript tests/test_01b_merge.R`
Expected:
- one line per live date, with `2026-10-18` re-fetched;
- `4 history rows relabelled`;
- a summary showing `overlap_mismatches 0`, `interpolated_hours 0` and `missing_hours 0`;
- then `OK test_01b_merge`.

- [ ] **Step 5: Commit.**

```bash
git add R tests data outputs/00_data_quality.csv && git commit -m "feat: gap-free hourly PSI with live merge, gap guard and quality report"
```

### Task 3: Daily and season tables, typed loaders, data dictionary

**Files:**
- Modify: `R/00_fns_data.R`, `R/00_load.R`
- Create: `R/02_daily.R`, `docs/data_dictionary.md`
- Test: `tests/test_02_daily.R`

**Interfaces:**
- Consumes: `load_hourly()` (Task 2); `data/raw/oni.txt`, downloaded from `https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt` if missing.
- Produces:
  - `read_oni(path = "data/raw/oni.txt") -> data.frame(year integer, oni_jja numeric)`: `read.table(header = TRUE)`, filtered to `SEAS == "JJA"`, using `ANOM`.
  - `build_daily(hourly, oni) -> data.frame` with exactly the daily contract columns, in contract order.
    - The date comes from `format(time, "%Y-%m-%d")` with the SGT `tz`, never `as.Date()` on a POSIXct.
    - `trigger_prev` is `trigger[match(date - 1, date)]`.
  - `build_season(daily) -> data.frame` with exactly the season contract columns, one row per year 2014–2026, in Sep–Oct.
  - `load_daily()` and `load_season()` in `R/00_load.R`: they return `date`/`peak_date` as `Date`, the trigger columns as logical, and counts as integer.
  - `R/02_daily.R` writes `data/psi_daily.csv` and `data/psi_season.csv`.
  - `docs/data_dictionary.md` lists every column of the three tables in backticks with its type, unit and meaning. It also covers:
    - the time-zone rule;
    - the trigger, season, persistence-pair and El Niño definitions;
    - the four relabelled rows (with the table from this plan);
    - the gap rule;
    - `DATA_END`;
    - a three-line "how to load" example;
    - sources.

- [ ] **Step 1: Write the failing test.**

```r
# tests/test_02_daily.R
source("R/00_load.R")
d <- load_daily(); s <- load_season()
k <- function(x) d[d$date == as.Date(x), ]
stopifnot(
  identical(names(d), c("date", "year", "month", "n_hours", "central8", "natmax", "trigger",
                        "trigger_prev", "in_season", "oni_jja", "el_nino")),
  inherits(d$date, "Date"), is.logical(d$trigger), is.logical(d$trigger_prev),
  d$date[1] == as.Date("2014-04-01"), k("2014-04-01")$n_hours == 23,               # SGT dates, not UTC
  all(d$n_hours[d$date > d$date[1] & d$date < max(d$date)] == 24),                  # no gaps
  identical(is.na(d$trigger), is.na(d$central8)),                                   # missing 08:00 => NA
  k("2015-09-25")$natmax == 322, k("2015-09-25")$central8 == 267, k("2026-10-16")$central8 == 226,
  isTRUE(k("2026-10-09")$trigger_prev), isFALSE(k("2026-10-02")$trigger_prev), is.na(d$trigger_prev[1]),
  sum(d$trigger[d$year == 2026 & d$in_season & d$date <= as.Date("2026-10-17")], na.rm = TRUE) == 23,
  identical(sort(unique(d$year[d$el_nino])), c(2015L, 2023L, 2026L)),
  abs(k("2026-10-01")$oni_jja - 1.80) < 0.15,                                       # NOAA revises slightly
  identical(names(s), c("year", "oni_jja", "el_nino", "days", "trigger_days", "trigger_rate",
                        "bad_days", "peak_natmax", "peak_date")),
  identical(s$year, 2014:2026), inherits(s$peak_date, "Date"),
  s$days[s$year == 2015] == 61, s$trigger_days[s$year == 2015] == 27, s$bad_days[s$year == 2015] == 46,
  s$peak_natmax[s$year == 2015] == 322, s$bad_days[s$year == 2026] >= 31
)
dict <- paste(readLines("docs/data_dictionary.md"), collapse = "\n")
cols <- unique(c(names(d), names(s), names(load_hourly())))
stopifnot(all(vapply(cols, function(n) grepl(paste0("`", n, "`"), dict, fixed = TRUE), logical(1))))
cat("OK test_02_daily\n")
```

- [ ] **Step 2: Run it to verify it fails.**

Run: `Rscript tests/test_02_daily.R`
Expected: FAIL with `could not find function "load_daily"`

- [ ] **Step 3: Implement the functions, `R/02_daily.R` and the loaders above, then write `docs/data_dictionary.md`.**

- [ ] **Step 4: Run the build and the test.**

Run: `Rscript R/02_daily.R && Rscript tests/test_02_daily.R`
Expected: `OK test_02_daily`

- [ ] **Step 5: Run everything once, then commit.**

Run: `Rscript R/run_all.R`
Expected: `OK test_01a_hist`, `OK test_01b_merge`, `OK test_02_daily`, then `ALL OK`

```bash
git add -A && git commit -m "feat: daily and season tables, typed loaders, data dictionary"
```

### Task 4: Shared chart style and charts 1–3

**Files:**
- Create: `R/00_style.R`, `R/07_figures_m1.R`
- Test: `tests/test_07_figures_m1.R`

**Interfaces:**
- Consumes: `load_daily()`, `load_season()` (Task 3); `outputs/03_inference.csv` from M2, only in the test.
- Produces:
  - `R/00_style.R`:
    - `PAL <- c(data = "#9E9E9E", accent = "#1F6FB2", ref = "#424242")`.
    - `save_chart(file, draw, title, subtitle = NULL) -> invisible(file)`:
      - Open the file with `png(file, width = 1600, height = 900, res = 150)` and set `par(mar = c(4, 4.5, 4.5, 1), las = 1, bty = "l")`.
      - Call `draw()`.
      - Add the title with `title(main = title, adj = 0, line = 2.2, font.main = 2)` and the subtitle with `mtext(subtitle, 3, adj = 0, line = 0.8, cex = 0.9, col = PAL["ref"])`.
      - Close with `dev.off()`.
    - This file is M2's and M3's starting point for charts 4 and 5.
  - `R/07_figures_m1.R` writes three charts and `outputs/m1_numbers.csv` (`name,value`). The names are `hours_total`, `relabelled_rows`, `haze_days_all`, `haze_days_sep_oct`, `sep_oct_share`, `bad_days_2015`, `bad_days_2026`, `peak_2026`, `peak_2026_date`, `p_hh`, `p_hc` and `n_pairs`. A haze day is a day with `natmax > 100`. `p_hh`, `p_hc` and `n_pairs` follow the contract's persistence rule.

| File | Draws | Title (numbers computed with `sprintf`) |
| --- | --- | --- |
| `fig1_timeline.png` | Daily `natmax`, thin grey line over the full span; days above 100 marked in the accent colour; dashed line at 100 labelled "Unhealthy (101+)" | `"2015 and 2026 stand apart: %d and %d haze days in Sep–Oct; no other year topped %d"` (from `psi_season.csv`) |
| `fig2_months.png` | Bars: haze days by calendar month, all years; Sep and Oct in the accent colour; count above each bar | `"%d%% of haze days since 2014 fell in September or October"` |
| `fig3_persistence.png` | Two bars, "after a hazy morning" (accent) and "after a clear morning" (grey), as percentages with labels | `"A hazy morning is followed by another %d%% of the time; a clear one, %d%%"` |

Every chart's subtitle ends with "Source: NEA via data.gov.sg" and the data end date, and every axis states its unit (PSI, days or %).

- [ ] **Step 1: Write the failing test.**

```r
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
cat("OK test_07_figures_m1\n")
```

- [ ] **Step 2: Run it to verify it fails.**

Run: `Rscript tests/test_07_figures_m1.R`
Expected: FAIL with `cannot open file 'outputs/m1_numbers.csv'`

- [ ] **Step 3: Implement `R/00_style.R` and `R/07_figures_m1.R` as above.** Share `R/00_style.R` with M2 and M3 the same day.

- [ ] **Step 4: Run the charts and the test, then look at them.**

Run: `Rscript R/07_figures_m1.R && Rscript tests/test_07_figures_m1.R`
Expected: `OK test_07_figures_m1`. Then open the three PNGs and check:
- each title states its number;
- no label overlaps;
- the axes show units;
- chart 1's accent marks cluster in 2015 and 2026.

- [ ] **Step 5: Commit.**

```bash
git add R/00_style.R R/07_figures_m1.R tests/test_07_figures_m1.R outputs && git commit -m "feat: shared chart style, charts 1-3, M1 numbers"
```

### Task 5: Hand-off, review of M3, and the freeze

**Files:**
- Modify: `R/00_fns_data.R` (`DATA_END`, at the freeze only)

- [ ] **Step 1 (Fri 23 Oct): Hand off the data.** Run `Rscript R/run_all.R` (expect `ALL OK`). Share the project folder (or zip `R/`, `data/`, `docs/` and `outputs/`) to the team Drive, with this message:

> Data is ready. In R, from the project folder: `source("R/00_load.R"); d <- load_daily(); s <- load_season()`. Column meanings and rules are in `docs/data_dictionary.md`. Use `trigger_prev` for the persistence numbers so ours match exactly. Charts must start from `R/00_style.R`. Numbers freeze on Sun 1 Nov; until then, M3 can use the snapshot values in the plan.

Expected: M2 runs `Rscript tests/test_01a_hist.R`, `test_01b_merge.R` and `test_02_daily.R` on their own laptop and all print `OK`.

- [ ] **Step 2 (Fri 30 – Sat 31 Oct): Review M3's simulation.** Run `Rscript tests/test_05_simulate.R` (expect `OK test_05`) and check in `outputs/05_prices.csv`:
  - `fair_price` is ordered normal < mixture < elnino.
  - `safe95_price` for the mixture is at least 1.5× the naive one.
  - `set.seed(1202)` is the first line that runs in `R/05_simulate.R`.
  - The snapshot numbers are replaced by reads of `outputs/03_inference.csv`.

  Send M3 any mismatch the same day.

- [ ] **Step 3 (Sun 1 Nov): Freeze the numbers.**
  - Set `DATA_END <- as.Date("2026-10-31")` in `R/00_fns_data.R`.
  - Run `Rscript R/run_all.R`. This fetches 18–31 Oct, including the partial 18 Oct file, and cuts at 31 Oct 23:00.
  - Expected: every test prints `OK`, then `ALL OK`, and `outputs/00_data_quality.csv` shows `last_time 2026-10-31 23:00` and `missing_hours 0`.
  - Copy `outputs/m1_numbers.csv` to `/tmp/m1_first.csv`, run `Rscript R/run_all.R` again, then run `cmp /tmp/m1_first.csv outputs/m1_numbers.csv`. Expected: no output (the files are identical).
  - Then `git tag numbers-frozen`, upload `outputs/` and `data/` to the team Drive as `frozen_2026-11-01`, and post the headline numbers from `m1_numbers.csv` and M3's `05_prices.csv` to the group.

- [ ] **Step 4: Commit.**

```bash
git add -A && git commit -m "chore: freeze data at 2026-10-31" && git tag numbers-frozen
```

### Task 6: Your segment (S2, 1:30)

**Files:**
- Modify: `video/script.md` (your section of M4's draft)

- [ ] **Step 1: Rewrite your lines from M4's draft** in your own words, in five beats:
  1. Why the data can be trusted: years and hours covered, and 0 missing hours after fixing 4 mislabelled rows (`hours_total`, `relabelled_rows`).
  2. Seasonality, with chart 2 (`sep_oct_share`).
  3. Persistence, with chart 3 (`p_hh`, `p_hc`): once a morning is hazy, the next one is hazy most of the time.
  4. One line on 2026 versus history (`bad_days_2026`, `bad_days_2015`).
  5. A bridge to M2: "So some seasons are far worse than others. What drives that?"
- [ ] **Step 2: Check the length.** Run `wc -w` on your section. Expected: 200 words or fewer (130 words a minute × 1.5 minutes).
- [ ] **Step 3: Check every number** against the frozen `outputs/m1_numbers.csv`, rounded the way you will say it.
- [ ] **Step 4: Rehearse with a stopwatch.** Expected: 1:25 to 1:35 at normal speed. Then record with your face on camera alongside the slides.

### Task 7: Word submission

**Files:**
- Create: `submission/AB1202AY2526S1-T_<X>-Grp_<Y>.docx` (X = seminar group, Y = group id)

- [ ] **Step 1 (Thu 22 Oct): Draft the references in APA 7.** Open each page and copy the exact title and date; entries marked [check] were not opened directly.
  - National Environment Agency. (2026). *Historical 24-hr PSI* [Data set]. data.gov.sg. https://data.gov.sg/datasets/d_b4cf557f8750260d229c49fd768e11ed/view
  - National Environment Agency. (2026). *Pollutant Standards Index (PSI)* [Real-time data set]. data.gov.sg. https://api-open.data.gov.sg/v2/real-time/api/psi
  - National Environment Agency. (2026, October 17). *Haze situation update (17 October 2026)*. https://www.nea.gov.sg/media/news/advisories/index/haze-situation-update-17-october-2026
  - Climate Prediction Center. (2026). *Oceanic Niño Index* [Data set]. National Oceanic and Atmospheric Administration. https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt
  - Swiss Re Corporate Solutions. (2024). *HazeShield* [Brochure]. https://corporatesolutions.swissre.com/dam/jcr:e3073142-5032-4b1f-9058-40c344e21102/HazeShield-brochure.2024-05-30-14-20-11.pdf
  - The Star. (2026, October 12). *At least five races and running club events cancelled due to haze pollution in Singapore*. https://www.thestar.com.my/aseanplus/aseanplus-news/2026/10/12/at-least-five-races-and-running-club-events-cancelled-due-to-haze-pollution-in-singapore
  - Mothership. (2026, September). [check: exact headline and day]. https://mothership.sg/2026/09/decathlon-half-marathon-shortened-haze/
  - Running.life. (n.d.). [check: exact page title]. Retrieved October 18, 2026, from https://running.life/en/event/garmin-run-marathon-series-singapore
  - Anthropic. (2026). *Claude* (Opus 5.5 version) [Large language model]. https://claude.ai
- [ ] **Step 2 (Wed 11 Nov): Fill the template** with single spacing, one-inch margins and fields 1–8:
  - Field 3: "Price the Haze: a haze-refund guarantee for outdoor events".
  - Fields 4–5: "N/A (original project; data from data.gov.sg/NEA and NOAA)".
  - Field 6: M4's YouTube link.
- [ ] **Step 3: Write the executive summary (field 7)** in four paragraphs, using only frozen numbers:
  - **Problem, about 60 words:** 2026 haze, cancelled races, no refunds.
  - **Analysis, about 180 words**, one sentence per source:
    - data and seasonality from `m1_numbers.csv`;
    - El Niño test and regression from M2's `03_inference.csv` and `04_regression.csv`;
    - prices from M3's `05_prices.csv`.
  - **Recommendation, about 100 words:** regime pricing set in September; moving flagship events in El Niño years; the gap HazeShield leaves.
  - **Limits, about 60 words:** only three El Niño seasons; one Central reading at 08:00 may not match a venue elsewhere; prices exclude admin costs.
- [ ] **Step 4: Check the summary.** Use Word's word count. Expected: 400 words or fewer. Then M2 checks every number against `outputs/`.
- [ ] **Step 5: Submit by Sat 14 Nov, 8pm.** Upload to the seminar site. Expected: the re-downloaded file opens, has the right name, all eight fields, and a video link that plays in a logged-out browser.
