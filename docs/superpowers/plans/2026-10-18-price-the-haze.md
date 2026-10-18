> Superseded on 18 Oct 2026 by 2026-10-18-remaining-work.md. Kept for history.

# Price the Haze Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the R evidence, five slide-ready charts, an 8-minute video and the Word submission for an AB1202 group project that prices "HazeGuard", a parametric haze-refund add-on for outdoor-event tickets in Singapore.

**Architecture:** Seven numbered base-R scripts form a pipeline: fetch → daily table → probability and inference → regression → simulation → sensitivity → figures. Each script reads `data/` and writes small CSVs to `outputs/`, which the slides and script quote by name. Each script has a sibling `tests/test_0N_*.R` built from `stopifnot()`; `R/run_all.R` runs everything and ends with `ALL OK`.

**Tech Stack:** R 4.5.2 (`/usr/local/bin/Rscript`, installed), base R graphics, `jsonlite` (installed). No other packages. Video: Zoom or Teams recording plus any editor. Submission: Microsoft Word.

**Spec:** Course outline Appendix 2 (`~/Downloads/AB1202 Statistics and Analysis Semester 1 AY 2026-27 - Course Outline(1).pdf`, pp. 11–13) and Idea 1 in [AB1202 Group Project: 10 Ranked Ideas](https://claude.ai/code/artifact/63e34478-20f7-4c93-a99a-99617a0b85d8). Product decisions D1–D9 below turn that idea into a buildable design.

## Research snapshot (data pulled 18 Oct 2026, 02:30 SGT)

"Haze day" means NEA 24-hour PSI above 100; NEA's Unhealthy band starts at 101. The raw files behind every number here are saved in `data/raw/`.

| Fact | Value | Source |
| --- | --- | --- |
| Historical hourly PSI | 108,864 rows, 5 regions, 1 Apr 2014 01:00 to 1 Sep 2026 00:00 | [data.gov.sg dataset](https://data.gov.sg/datasets/d_b4cf557f8750260d229c49fd768e11ed/view) |
| Live API covers the gap | `?date=YYYY-MM-DD` returns 24 hourly readings; no key needed; 48 days fetched with 0 failures | data.gov.sg real-time PSI API |
| 2026 season so far (1 Sep–18 Oct) | First haze day 4 Sep; 32 days with any region above 100; 23 days with Central above 100 at 08:00; 5 days above 200 | Our pull |
| 2026 peak | National daily max 229 on 16 Oct; Central 186 at 23:00 on 9 Oct | Our pull |
| NEA latest (17 Oct, 7pm) | 24-hr PSI 130–199; forecast for 18 Oct 150–220; showers and a wind shift on 19–20 Oct may reduce Kalimantan smoke | [NEA update, 17 Oct](https://www.nea.gov.sg/media/news/advisories/index/haze-situation-update-17-october-2026) |
| Bad years 2014–2025 (any region above 100, full year) | 2014: 9, 2015: 46, 2016: 4, 2017: 1, 2019: 11, 2021: 2, 2023: 2, 2025: 1; other years 0 | Our pull |
| Seasonality | 65 of the 76 haze days in 2014–2025 fell in September or October | Our pull |
| Persistence (Sep–Oct, Central 08:00) | P(haze \| yesterday hazy) = 0.64; P(haze \| yesterday clear) = 0.03 | Our pull |
| El Niño | NOAA ONI for Jun–Aug 2026 = +1.80 (Jul–Sep +2.16), stronger than 2015's +1.44. Seasons with Jun–Aug ONI ≥ 0.5: 2015, 2023, 2026 | [NOAA ONI table](https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt) |
| El Niño effect | Sep–Oct trigger rate: 30.2% (51/169 days) in El Niño seasons vs 0.8% (5/610) otherwise; two-proportion test p ≈ 4e-38 | Our pull |
| Regression probe (Aug–Nov, Central 08:00) | +17.6 PSI per +1.0 ONI (R² 0.39); El Niño dummy +23.4 (R² 0.29) | Our pull |
| Swiss Re HazeShield | Pays only from 20 cumulative days above 100 (20 days 20%, 25: 40%, 30: 60%, 35: 80%, 40+: 100%). Only 2015 would have paid in 2014–2025; 2026 is already at the 60% tier | [Swiss Re brochure](https://corporatesolutions.swissre.com/dam/jcr:e3073142-5032-4b1f-9058-40c344e21102/HazeShield-brochure.2024-05-30-14-20-11.pdf) |
| Ticket price | Garmin Run Singapore 10K, 25 Oct 2026: S$85 early bird, S$105 normal | [running.life](https://running.life/en/event/garmin-run-marathon-series-singapore) |
| Real cancellations | At least five runs called off 7–11 Oct, including the ticketed Circuit Blazers Race; one run club is refunding 280 people. Kiprun half marathon was cut to 10 km in late September | [The Star](https://www.thestar.com.my/aseanplus/aseanplus-news/2026/10/12/at-least-five-races-and-running-club-events-cancelled-due-to-haze-pollution-in-singapore), [Mothership](https://mothership.sg/2026/09/decathlon-half-marathon-shortened-haze/) |
| Simulation probe (seed 1202) | Fair price per S$105 ticket: S$0.8 normal year, S$33 El Niño year. The 95% "safe" price for an 8-event season is S$26 if seasons are treated alike and S$52 once El Niño seasons are modelled separately | Our pull |

## Product decisions (D1–D9)

- **D1 Product and buyer:** an outdoor-event organiser sells "HazeGuard" as an optional add-on at checkout. An insurer, or the organiser's own reserve, pays the refunds.
- **D2 Trigger:** the NEA 24-hour PSI for the **Central** region at **08:00 SGT** on event day is **above 100**. It is published hourly and checkable by anyone. 08:00 is when morning events decide whether to flag off. Central covers Marina Bay, Kallang and the F1 circuit.
- **D3 Payout:** a 100% refund of a **S$105** ticket (the Garmin Run Singapore 10K normal fee).
- **D4 Season:** 1 Sep to 31 Oct (61 days). Event days are days 7, 14, …, 56 of the window, giving 8 weekly events.
- **D5 Book:** 8 events × 5,000 tickets = 40,000 tickets per season.
- **D6 Prices reported:**
    - Fair price = expected payout per ticket.
    - Safe price = 95th percentile of the season payout ÷ 40,000.
- **D7 El Niño flag:** NOAA ONI for Jun–Aug ≥ 0.5. This is published in early September, before most events, so the price can depend on it.
- **D8 Simulation:** 10,000 seasons with `set.seed(1202)`, run under four scenarios:
    - `naive`: Binomial(8, p_all), every season treated alike.
    - `normal` and `elnino`: a two-state Markov chain over 61 days, using that regime's transition probabilities.
    - `mixture`: El Niño with probability 3/13 (3 of the 13 seasons), then the chain for that regime.
- **D9 Sensitivity:**
    - A threshold of 150 instead of 100.
    - The national maximum instead of Central at 08:00.
    - The El Niño trigger rate with 2015, 2023 or 2026 left out.

**Recommendation the video argues** (final numbers come from `outputs/`, not this table):
- Price HazeGuard by regime: about S$1 a ticket in a normal year and about S$33 in an El Niño year, announced after NOAA's September update.
- In El Niño years, organisers should move flagship events out of September and October.
- Swiss Re's HazeShield already covers catastrophic seasons; nothing covers the single bad Sunday.

## Global Constraints

- Video: "a group presentation video (text link in docx/pdf) not longer than 8 minutes (15%). Record video at normal speed."
- "Every group member must show his/her face and participate in the presentation."
- Content: "(1) introduce the business problem and your recommendation, (2) present a statistical analysis of the problem using R, and (3) discuss the implications of the analysis for the business problem and recommendation"
- "Please only use freely available data and do not pay for data."
- "Statistical “theory” should not be the focus. Rather, explain how statistics can be the “enabler” of your solution."
- Submission: "MS Word file and must follow the template"; name “AB1202AY2526S1-T_X-Grp_Y.docx” (X = seminar group, Y = group id); "Designate one group member to submit this assignment."
- Deadline: "due by Week 13, Sunday, Nov 15, 2026 at/before 1:00 pm. Late submissions will be penalized: -15% for 0-3 hrs, -50% for 3-24 hrs, and -100% >24 hrs."
- Template fields 1–8, "single spacing; one-inch margins on all sides"; "An executive summary of the presentation (max 400 words)"; "References (to data sources, articles, and AI tools used)" in APA style.
- Reflection, individual: "cover page … A4 paper, 11-pt font size, & 1.5 line spacing, with a one-inch margin on each side"; GradeWay peer reviews for every teammate.
- Quiz 2 is Tuesday, November 10, 2026. Plan no project work for 9–10 Nov.
- Reproducibility (team rule): every random step uses `set.seed(1202)`; all scripts run from the project root with `Rscript R/run_all.R`.

## Review Focus

1. **The 2026 season is missing.** The historical CSV ends at 2026-09-01 00:00, so an analysis without the live pull silently drops the most important season. Expect: the max date is at least 2026-10-17 and Central at 2026-10-09 23:00 is 186 (Task 1 test).
2. **Seam duplicate and malformed timestamp.** 2026-09-01 00:00 appears in both sources, and one historical row reads `4/4/2016 010:00`. Expect: no duplicate times, and the bad row dropped with a message (Task 1 test).
3. **Missing 08:00 reading.** A day without an 08:00 row (the partial current day, outages) must give an NA trigger, never FALSE. Otherwise "no data" counts as "clean air" (Task 2 test).
4. **Treating seasons as alike.** The naive model matches the mixture's average payout but has about half its 95th percentile, so the safe price is badly understated. Expect: both scenarios are reported side by side (Task 5 test).
5. **Small-sample fragility.** Only three El Niño seasons exist, and the rate rests heavily on 2015 and 2026. Expect: the season-level confidence interval is reported next to the day-level one (Task 3 test), plus a leave-one-season-out table (Task 6 test).

## File structure

```
AB1202-haze/
  R/run_all.R          sources R/0*_*.R in order, then tests/test_*.R; prints "ALL OK"
  R/01_fetch.R         download and merge hourly PSI   -> data/psi_hourly.csv
  R/02_daily.R         daily table + ONI + triggers    -> data/psi_daily.csv
  R/03_inference.R     Module 1–2 numbers              -> outputs/03_inference.csv
  R/04_regression.R    Module 3 regression             -> outputs/04_regression.csv
  R/05_simulate.R      Module 3 simulation and prices  -> outputs/05_prices.csv, outputs/05_threeday.csv
  R/06_sensitivity.R   robustness + HazeShield check   -> outputs/06_sensitivity.csv, outputs/06_hazeshield.csv
  R/07_figures.R       five slide charts               -> outputs/figures/fig1..fig5 *.png
  tests/test_01_fetch.R … tests/test_07_figures.R
  data/raw/            psi_hist.csv, live/YYYY-MM-DD.json, oni.txt (18 Oct snapshot already saved)
  video/storyboard.md, video/script.md
  submission/          the Word file
```

## Timeline and owners

Roles (five members; with four, one person takes both B and C):
- A: data
- B: probability and inference
- C: regression
- D: simulation
- E: story and video. E opens and closes the video.

| Dates | Tasks | Owner | Gate |
| --- | --- | --- | --- |
| Mon 19 – Fri 23 Oct | 0, 1, 2 | A (+ everyone for Task 0) | `test_01`, `test_02` pass |
| Sat 24 Oct – Sun 1 Nov | 3, 4, 5, 6, 7 | B, C, D, A | Sun 1 Nov: re-run Task 1 to include all of October, then freeze numbers with `Rscript R/run_all.R` showing ALL OK |
| Mon 2 – Wed 4 Nov | 8 (storyboard, script) | E + all | Script ≤ 975 words |
| Thu 5 – Sun 8 Nov | 9 (slides, recording) | all | Rough cut ≤ 7:59 |
| Mon 9 – Tue 10 Nov | none (Quiz 2 on 10 Nov). Bring the rough cut to the Week 13 project consultation | — | — |
| Wed 11 – Fri 13 Nov | 9 (edit, upload), 10 (Word file) | E, A | Link works logged out |
| Sat 14 Nov, 8pm | 10 (submit) | designated member | Submitted; 17 hours of buffer before the deadline |
| After submission | Reflection + GradeWay | each member | — |

---

### Task 0: Project skeleton and runner

**Files:**
- Create: `R/run_all.R`. `outputs/` is committed, not ignored, so the slide builder gets the frozen charts without running R.

**Interfaces:**
- Produces: `Rscript R/run_all.R` sources every `R/0[1-7]_*.R` in name order (each in `local = new.env()`), then every `tests/test_*.R`, then prints `ALL OK`.

- [ ] **Step 1: Create folders and init git**

Run: `cd ~/AB1202-haze && mkdir -p R tests outputs/figures video submission && git init`
Expected: `Initialized empty Git repository`

- [ ] **Step 2: Write `R/run_all.R`** as described in Interfaces (≈5 lines; `list.files("R", "^0[1-7]_.*\\.R$")`).

- [ ] **Step 3: Run it with no scripts yet**

Run: `Rscript R/run_all.R`
Expected: `ALL OK`

- [ ] **Step 4: Fill in roles.** Put names against A–E in the Timeline table above and share this file with the group.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "chore: project skeleton, runner, 18 Oct data snapshot"
```

### Task 1: Fetch and merge hourly PSI

**Files:**
- Create: `R/01_fetch.R`
- Test: `tests/test_01_fetch.R`

**Interfaces:**
- Produces: `data/psi_hourly.csv` with columns `time` (character `"YYYY-MM-DD HH:MM"`, SGT, sorted, unique), `north`, `south`, `east`, `west`, `central` (integers, no NA).

- [ ] **Step 1: Write the failing test**

```r
# tests/test_01_fetch.R
x <- read.csv("data/psi_hourly.csv", stringsAsFactors = FALSE)
stopifnot(
  identical(names(x), c("time", "north", "south", "east", "west", "central")),
  !anyDuplicated(x$time),                                        # seam 2026-09-01 00:00 deduped
  x$time[1] == "2014-04-01 01:00",
  as.Date(substr(max(x$time), 1, 10)) >= as.Date("2026-10-17"),  # live 2026 season present
  x$central[x$time == "2015-09-25 08:00"] == 267,
  x$central[x$time == "2026-10-09 23:00"] == 186,
  !anyNA(x[-1]),
  nrow(x) >= 109900
)
cat("OK test_01\n")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Rscript tests/test_01_fetch.R`
Expected: FAIL with `cannot open file 'data/psi_hourly.csv'`

- [ ] **Step 3: Implement `R/01_fetch.R`**

Functions, then a main block that calls them and writes the CSV:
- `fetch_hist(dest = "data/raw/psi_hist.csv")`
    - Skip if the file exists.
    - Otherwise read `jsonlite::fromJSON("https://api-open.data.gov.sg/v1/public/api/datasets/d_b4cf557f8750260d229c49fd768e11ed/poll-download")$data$url` and `download.file()` it.
- `fetch_live(from = as.Date("2026-09-01"), to = Sys.Date(), dir = "data/raw/live")`
    - For each date, request `https://api-open.data.gov.sg/v2/real-time/api/psi?date=<date>` and save it as `<dir>/<date>.json`.
    - Skip a date only if its file exists **and** the date is at least 2 days before `to`, so partial days get refreshed.
    - On error, `Sys.sleep(10)` and retry once. The rate-limit window is 10 seconds.
    - Print one `message()` line per date (`2026-10-09 ok` / `FAIL`).
- `read_hist(path)`
    - Parse column 1 with `as.POSIXct(format = "%d/%m/%Y %H:%M", tz = "Asia/Singapore")`.
    - Drop rows that fail to parse and `message()` how many (1 expected).
- `read_live(dir)`
    - For each file: `fromJSON(f)$data$items`.
    - Time = `as.POSIXct(substr(timestamp, 1, 19), format = "%Y-%m-%dT%H:%M:%S", tz = "Asia/Singapore")`.
    - Values = `readings$psi_twenty_four_hourly[c("north","south","east","west","central")]`.
- `merge_psi(hist, live)`
    - `rbind(hist, live[!live$time %in% hist$time, ])`, then order by time.
    - Write `time` with `format(time, "%Y-%m-%d %H:%M")`.

- [ ] **Step 4: Run to verify it passes**

Run: `Rscript R/01_fetch.R && Rscript tests/test_01_fetch.R`
Expected: one message per live date, `1 unparseable historical row dropped`, then `OK test_01`

- [ ] **Step 5: Commit**

```bash
git add R/01_fetch.R tests/test_01_fetch.R data && git commit -m "feat: fetch and merge hourly PSI 2014-2026"
```

### Task 2: Daily table, El Niño flag, trigger

**Files:**
- Create: `R/02_daily.R`
- Test: `tests/test_02_daily.R`

**Interfaces:**
- Consumes: `data/psi_hourly.csv` (Task 1); `data/raw/oni.txt`, downloaded from `https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt` if missing.
- Produces: `data/psi_daily.csv`. Columns, in this order:
    - `date` (`"YYYY-MM-DD"`), `year`, `month`.
    - `central8`: Central at 08:00, NA if there is no 08:00 row.
    - `natmax`: the max over 5 regions × all hours of that date.
    - `trigger`: `central8 > 100`, NA when `central8` is NA.
    - `oni_jja`: the `ANOM` of the `SEAS == "JJA"` row for that year.
    - `el_nino`: `oni_jja >= 0.5`.

- [ ] **Step 1: Write the failing test**

```r
# tests/test_02_daily.R
d <- read.csv("data/psi_daily.csv", stringsAsFactors = FALSE)
so <- d[d$month %in% 9:10 & d$date <= "2026-10-17", ]
stopifnot(
  identical(names(d), c("date", "year", "month", "central8", "natmax", "trigger", "oni_jja", "el_nino")),
  identical(is.na(d$trigger), is.na(d$central8)),           # missing 08:00 => NA, never FALSE
  sum(so$trigger[so$year == 2015], na.rm = TRUE) == 27,
  sum(so$trigger[so$year == 2026], na.rm = TRUE) == 23,
  d$natmax[d$date == "2015-09-25"] == 322,
  identical(sort(unique(d$year[d$el_nino])), c(2015L, 2023L, 2026L)),
  abs(d$oni_jja[d$date == "2026-10-01"] - 1.80) < 0.15      # NOAA revises ONI slightly
)
cat("OK test_02\n")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Rscript tests/test_02_daily.R`
Expected: FAIL with `cannot open file 'data/psi_daily.csv'`

- [ ] **Step 3: Implement `R/02_daily.R`**
    - `read_oni(path)` → `data.frame(year, oni_jja)`, using `read.table(header = TRUE)` and filtering to `SEAS == "JJA"`.
    - `build_daily(hourly, oni)` → the table above, using `aggregate(..., max)` for `natmax` and a merge for the 08:00 row.

- [ ] **Step 4: Run to verify it passes**

Run: `Rscript R/02_daily.R && Rscript tests/test_02_daily.R`
Expected: `OK test_02`

- [ ] **Step 5: Commit**

```bash
git add R/02_daily.R tests/test_02_daily.R data/psi_daily.csv && git commit -m "feat: daily PSI table with El Nino flag and trigger"
```

### Task 3: Module 1–2: probabilities, intervals, El Niño test

**Files:**
- Create: `R/03_inference.R`
- Test: `tests/test_03_inference.R`

**Interfaces:**
- Consumes: `data/psi_daily.csv` (Task 2).
- Produces: `outputs/03_inference.csv` in long format with columns `name,value`. Exact names:
    - Trigger rates: `n_days`, `p_all`, `p_elnino`, `p_normal`.
    - Transition probabilities: `p_hh`, `p_hc`, `p_hh_elnino`, `p_hc_elnino`, `p_hh_normal`, `p_hc_normal`.
    - Intervals: `ci_day_lo`, `ci_day_hi`, `ci_season_lo`, `ci_season_hi`.
    - El Niño test: `p_value_elnino`.
    - Prices and binomial check: `fair_all`, `fair_elnino`, `fair_normal`, `p_any8_iid`.

- [ ] **Step 1: Write the failing test**

```r
# tests/test_03_inference.R
k <- read.csv("outputs/03_inference.csv"); v <- setNames(k$value, k$name)
near <- function(x, target, tol) abs(x - target) <= tol
stopifnot(
  near(v[["p_all"]], 0.072, 0.015), near(v[["p_elnino"]], 0.30, 0.06), near(v[["p_normal"]], 0.008, 0.005),
  near(v[["p_hh"]], 0.64, 0.08), near(v[["p_hc"]], 0.03, 0.015),
  v[["ci_season_hi"]] - v[["ci_season_lo"]] > v[["ci_day_hi"]] - v[["ci_day_lo"]],  # seasons are the honest unit
  v[["p_value_elnino"]] < 1e-10,
  near(v[["fair_all"]], 105 * v[["p_all"]], 1e-9),
  near(v[["p_any8_iid"]], 1 - (1 - v[["p_all"]])^8, 1e-9)
)
cat("OK test_03\n")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Rscript tests/test_03_inference.R`
Expected: FAIL with `cannot open file 'outputs/03_inference.csv'`

- [ ] **Step 3: Implement `R/03_inference.R`**
    - **Sample:** `month %in% 9:10 & !is.na(trigger)`.
    - **Transitions:** pairs of consecutive dates (`diff(date) == 1`) within the sample. `p_hh` = mean of today's trigger where yesterday triggered; `p_hc` = where yesterday did not. Compute the same per regime.
    - **Day interval:** `ci_day` = `prop.test(sum(trigger), n)$conf.int`.
    - **Season interval:** `ci_season` = `t.test(per-season mean trigger)$conf.int`, with the lower bound clamped at 0.
    - **El Niño test:** `p_value_elnino` = `prop.test(c(x_elnino, x_normal), c(n_elnino, n_normal))$p.value`.
    - **Prices:** `fair_*` = 105 × the matching `p_*`.

- [ ] **Step 4: Run to verify it passes**

Run: `Rscript R/03_inference.R && Rscript tests/test_03_inference.R`
Expected: `OK test_03`. As of 18 Oct, `ci_day` ≈ [0.055, 0.093] and `ci_season` ≈ [0, 0.184]. Put that contrast on the slide: day-by-day counting overstates certainty.

- [ ] **Step 5: Commit**

```bash
git add R/03_inference.R tests/test_03_inference.R && git commit -m "feat: trigger probabilities, intervals, El Nino test"
```

### Task 4: Module 3a: regression with dummy coding

**Files:**
- Create: `R/04_regression.R`
- Test: `tests/test_04_regression.R`

**Interfaces:**
- Consumes: `data/psi_daily.csv` (Task 2).
- Produces: `outputs/04_regression.csv` with columns `model` (`"oni"` | `"dummy"`), `term`, `estimate`, `std_error`, `p_value`.
    - Terms are as `lm` names them (`(Intercept)`, `factor(month)9`, `factor(month)10`, `factor(month)11`, `oni_jja` or `el_ninoTRUE`).
    - Each model also gets a `r_squared` row (other columns NA).
    - Model `oni` also gets rows `pred_oct_oni_0` and `pred_oct_oni_1.8`: the predicted Central 08:00 PSI in October.

- [ ] **Step 1: Write the failing test**

```r
# tests/test_04_regression.R
r <- read.csv("outputs/04_regression.csv", stringsAsFactors = FALSE)
g <- function(m, t) r[r$model == m & r$term == t, ]
stopifnot(
  g("oni", "oni_jja")$estimate > 12, g("oni", "oni_jja")$estimate < 24, g("oni", "oni_jja")$p_value < 0.001,
  g("dummy", "el_ninoTRUE")$estimate > 15, g("dummy", "el_ninoTRUE")$p_value < 0.001,
  g("oni", "factor(month)10")$estimate > 0,
  g("oni", "r_squared")$estimate > g("dummy", "r_squared")$estimate,
  g("oni", "pred_oct_oni_1.8")$estimate > g("oni", "pred_oct_oni_0")$estimate
)
cat("OK test_04\n")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Rscript tests/test_04_regression.R`
Expected: FAIL with `cannot open file 'outputs/04_regression.csv'`

- [ ] **Step 3: Implement `R/04_regression.R`**
    - Data: `month %in% 8:11 & !is.na(central8)`, with August as the baseline month.
    - Models:
        - `m_oni <- lm(central8 ~ factor(month) + oni_jja, data = a)`
        - `m_dummy <- lm(central8 ~ factor(month) + el_nino, data = a)`
    - Coefficient rows come from `summary(m)$coefficients`.
    - Predictions: `predict(m_oni, data.frame(month = 10, oni_jja = c(0, 1.8)))`.
    - Expected as of 18 Oct: `oni_jja` ≈ +17.6, R² ≈ 0.39; `el_ninoTRUE` ≈ +23.4, R² ≈ 0.29.

- [ ] **Step 4: Run to verify it passes**

Run: `Rscript R/04_regression.R && Rscript tests/test_04_regression.R`
Expected: `OK test_04`

- [ ] **Step 5: Commit**

```bash
git add R/04_regression.R tests/test_04_regression.R && git commit -m "feat: PSI regression on month dummies and ONI"
```

### Task 5: Module 3b: Monte Carlo pricing

**Files:**
- Create: `R/05_simulate.R`
- Test: `tests/test_05_simulate.R`

**Interfaces:**
- Consumes: `outputs/03_inference.csv` (`p_all`, `p_hh`, `p_hc`, `p_hh_elnino`, `p_hc_elnino`, `p_hh_normal`, `p_hc_normal`).
- Produces:
    - `outputs/05_prices.csv` with columns `scenario` (`normal`, `elnino`, `mixture`, `naive`), `mean_hits`, `p_any`, `p_ge3`, `q95_hits`, `fair_price`, `safe95_price`.
    - `outputs/05_threeday.csv` with columns `model` (`markov`, `iid`), `p_all3`.

- [ ] **Step 1: Write the failing test**

```r
# tests/test_05_simulate.R
p <- read.csv("outputs/05_prices.csv", stringsAsFactors = FALSE); g <- function(s, col) p[p$scenario == s, col]
t3 <- read.csv("outputs/05_threeday.csv", stringsAsFactors = FALSE)
stopifnot(
  identical(sort(p$scenario), c("elnino", "mixture", "naive", "normal")),
  g("normal", "fair_price") < 2,
  g("elnino", "fair_price") > 25, g("elnino", "fair_price") < 42,
  abs(g("mixture", "mean_hits") - g("naive", "mean_hits")) < 0.2,   # same average...
  g("mixture", "safe95_price") >= 1.5 * g("naive", "safe95_price"), # ...much fatter tail
  t3$p_all3[t3$model == "markov"] > 10 * t3$p_all3[t3$model == "iid"]
)
cat("OK test_05\n")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Rscript tests/test_05_simulate.R`
Expected: FAIL with `cannot open file 'outputs/05_prices.csv'`

- [ ] **Step 3: Implement `R/05_simulate.R`**

**Constants at the top:** `set.seed(1202)`; `N <- 10000`; `days <- 61`; `ev <- seq(7, 56, by = 7)`; `price <- 105`; `p_season_elnino <- 3/13`.

**`sim_season(hh, hc, days = 61)`** returns a logical vector of length `days`.
- Day 1 is hazy with the stationary probability `hc / (1 - hh + hc)`.
- After that, each day is hazy with probability `hh` if yesterday was hazy, else `hc`.
- Use a for-loop; the course's Week 12 R point is the for-loop.
- Directly after the definition, add a self-check: `stopifnot(all(sim_season(1, 1)), !any(sim_season(0, 0)))`.

**`hits(regime_prob, n = N)`** returns an integer vector.
- For each season, the regime is El Niño with probability `regime_prob`.
- Run `sim_season` with that regime's (hh, hc) and count `sum(s[ev])`.

**Scenarios:**
- `normal = hits(0)`, `elnino = hits(1)`, `mixture = hits(p_season_elnino)`.
- `naive = rbinom(N, length(ev), p_all)`.

**Per-scenario columns:**
- `q95_hits = quantile(x, .95, type = 1)`.
- `fair_price = mean_hits * price / length(ev)`.
- `safe95_price = q95_hits * price / length(ev)`.

**Three-day event (`05_threeday.csv`):**
- `markov` = `mean(replicate(N, all(sim_season(p_hh, p_hc, 3))))`.
- `iid` = `p_all^3`.

- [ ] **Step 4: Run to verify it passes**

Run: `Rscript R/05_simulate.R && Rscript tests/test_05_simulate.R`
Expected: `OK test_05`. Figures as of 18 Oct:
- Fair price: about S$0.8 (normal), S$33 (El Niño), S$8 (mixture).
- Safe price: S$26 (naive) against S$52 (mixture).
- Three hazy days in a row: P ≈ 0.03 (Markov) against 0.0004 (iid).

- [ ] **Step 5: Commit**

```bash
git add R/05_simulate.R tests/test_05_simulate.R && git commit -m "feat: Markov-chain season simulation and HazeGuard prices"
```

### Task 6: Sensitivity and HazeShield comparison

**Files:**
- Create: `R/06_sensitivity.R`
- Test: `tests/test_06_sensitivity.R`

**Interfaces:**
- Consumes: `data/psi_daily.csv` (Task 2).
- Produces:
    - `outputs/06_sensitivity.csv` with columns `variant`, `p_trigger`, `fair_price`. Rows, in this order: `base`, `threshold_150`, `national_max`, `elnino_drop_2015`, `elnino_drop_2023`, `elnino_drop_2026`.
    - `outputs/06_hazeshield.csv` with columns `year`, `bad_days`, `payout_pct`.

- [ ] **Step 1: Write the failing test**

```r
# tests/test_06_sensitivity.R
s <- read.csv("outputs/06_sensitivity.csv", stringsAsFactors = FALSE)
h <- read.csv("outputs/06_hazeshield.csv"); pay <- setNames(h$payout_pct, h$year)
stopifnot(
  identical(s$variant, c("base", "threshold_150", "national_max", "elnino_drop_2015", "elnino_drop_2023", "elnino_drop_2026")),
  s$p_trigger[s$variant == "threshold_150"] < s$p_trigger[s$variant == "base"],
  s$p_trigger[s$variant == "national_max"] > s$p_trigger[s$variant == "base"],
  pay[["2015"]] == 100, pay[["2026"]] >= 60,
  all(pay[!names(pay) %in% c("2015", "2026")] == 0)
)
cat("OK test_06\n")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Rscript tests/test_06_sensitivity.R`
Expected: FAIL with `cannot open file 'outputs/06_sensitivity.csv'`

- [ ] **Step 3: Implement `R/06_sensitivity.R`**

All variants use September–October days; `fair_price = 105 * p_trigger`.
- `base`: Central 08:00 above 100, all years.
- `threshold_150`: Central 08:00 above 150.
- `national_max`: `natmax > 100`.
- `elnino_drop_Y`: the trigger rate over El Niño seasons, excluding year Y.

HazeShield: `bad_days` = Sep–Oct count of `natmax > 100` per year. `payout_pct = c(0, 20, 40, 60, 80, 100)[findInterval(bad_days, c(0, 20, 25, 30, 35, 40))]`. Note on the slide that HazeShield's real risk period may be the full year; Sep–Oct holds about 90% of haze days.

- [ ] **Step 4: Run to verify it passes**

Run: `Rscript R/06_sensitivity.R && Rscript tests/test_06_sensitivity.R`
Expected: `OK test_06`

- [ ] **Step 5: Commit**

```bash
git add R/06_sensitivity.R tests/test_06_sensitivity.R && git commit -m "feat: sensitivity checks and HazeShield comparison"
```

### Task 7: Five slide charts

**Files:**
- Create: `R/07_figures.R`
- Test: `tests/test_07_figures.R`

**Interfaces:**
- Consumes: `data/psi_daily.csv`, `outputs/03_inference.csv`, `outputs/05_prices.csv`.
- Produces: five PNGs in `outputs/figures/`, each `png(width = 1600, height = 900, res = 150)` (16:9 slides). Every title states the finding. Any number in a title is computed from the data with `sprintf`, never typed.

| File | Shows | Title pattern |
| --- | --- | --- |
| `fig1_timeline.png` | National daily max, Apr 2014 → latest, dashed line at 100 labelled "Unhealthy (101+)" | "Only 2015 and 2026 had weeks of unhealthy air" |
| `fig2_months.png` | Count of days `natmax > 100` by month, all years; Sep and Oct in the accent colour | "%d%% of haze days since 2014 fell in September or October" |
| `fig3_persistence.png` | Two bars: `p_hh` and `p_hc` | "A hazy morning is followed by another %d%% of the time" |
| `fig4_elnino.png` | Per-season Sep–Oct trigger rate vs `oni_jja`, each point labelled with its year, vertical line at 0.5 | "El Niño seasons carry almost all the haze risk" |
| `fig5_prices.png` | `fair_price` and `safe95_price` by scenario, with a horizontal line at the S$105 ticket price | "A haze refund costs about S$%.0f a ticket normally and S$%.0f in an El Niño year" |

- [ ] **Step 1: Write the failing test**

```r
# tests/test_07_figures.R
f <- file.path("outputs/figures", c("fig1_timeline.png", "fig2_months.png", "fig3_persistence.png", "fig4_elnino.png", "fig5_prices.png"))
stopifnot(all(file.exists(f)), all(file.size(f) > 20000))
cat("OK test_07\n")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Rscript tests/test_07_figures.R`
Expected: FAIL with `all(file.exists(f)) is not TRUE`

- [ ] **Step 3: Implement `R/07_figures.R`** using base graphics (`plot`, `barplot`, `abline`, `text`). Use one grey for the data and one accent colour for what the title is about.

- [ ] **Step 4: Run to verify it passes, then look**

Run: `Rscript R/07_figures.R && Rscript tests/test_07_figures.R`
Expected: `OK test_07`. Then open all five PNGs and confirm three things: each title states its number, no label overlaps, and the axes show units (PSI, %, S$).

- [ ] **Step 5: Freeze the numbers (Sun 1 Nov)**

Run: `Rscript R/run_all.R`
Expected: `OK test_01` … `OK test_07`, then `ALL OK`. Tag it: `git tag numbers-frozen`.

- [ ] **Step 6: Commit**

```bash
git add R/07_figures.R tests/test_07_figures.R outputs && git commit -m "feat: five slide charts and frozen outputs"
```

### Task 8: Storyboard and script

**Files:**
- Create: `video/storyboard.md`, `video/script.md`

**Interfaces:**
- Consumes: `outputs/*.csv` and `outputs/figures/*.png` from the frozen run. Every number spoken is quoted by its output name in the storyboard.

The storyboard is fixed as follows (total 7:30, with 30 seconds of buffer under the 8:00 cap):

| # | Segment | Presenter | Time | Visual | Numbers (output names) |
| --- | --- | --- | --- | --- | --- |
| S1 | Hook and recommendation: "On 16 Oct the PSI hit 229. Runners paid S$105 and most race terms say no refund." Propose HazeGuard and its two prices | E | 1:00 | Title slide, then fig1 | 2026 peak `natmax`; `fair_price` normal and elnino |
| S2 | When and how haze hits: September and October, and it persists day to day | A | 1:30 | fig2, fig3 | Sep–Oct share; `p_all`; `p_hh`; `p_hc` |
| S3 | Is El Niño the driver? Test plus honest intervals | B | 1:15 | fig4 | `p_elnino`; `p_normal`; `p_value_elnino`; `ci_day_*` vs `ci_season_*` |
| S4 | How much worse? The regression | C | 1:15 | Coefficient slide (4 rows max) | `oni_jja`; `factor(month)10`; `r_squared`; `pred_oct_oni_0` vs `pred_oct_oni_1.8` |
| S5 | Pricing the refund: the simulation | D | 1:30 | fig5, plus one line on the 3-day risk | `fair_price`, `safe95_price` for all scenarios; `p_all3` Markov vs iid |
| S6 | What organisers should do, the limits, and the close | E | 1:00 | Recommendation slide | HazeShield 2026 tier; leave-one-out range from `06_sensitivity.csv` |

- [ ] **Step 1: Check the Garmin Run Singapore result.** Did the 25 Oct race run, get shortened or get cancelled? Put the answer in S1's opening line.
- [ ] **Step 2: Write `video/storyboard.md`** as the table above, plus one slide sketch per row.
- [ ] **Step 3: Write `video/script.md`.** Each speaker's lines go under their segment heading. Introduce every statistic with the business question it answers ("How often would we pay out?"), not the method name.
- [ ] **Step 4: Check the length**

Run: `wc -w video/script.md`
Expected: ≤ 975 words (130 words a minute × 7.5 minutes)

- [ ] **Step 5: Cross-check the numbers.** Every number in `script.md` must match its value in `outputs/` (rounded). Fix any mismatch.
- [ ] **Step 6: Commit**

```bash
git add video && git commit -m "docs: storyboard and script"
```

### Task 9: Slides, recording and edit

**Files:**
- Create: slide deck (path or link recorded in `video/storyboard.md`), final video file (kept outside git)

- [ ] **Step 1: Build the slides.** One slide per storyboard visual (about 10 slides), using the PNGs from `outputs/figures/` unchanged.
- [ ] **Step 2: Timed rehearsal.** One full run-through with a stopwatch. Expected: 7:15–7:45 at normal speaking pace.
- [ ] **Step 3: Record.** Each presenter records with their face visible on camera alongside the slides, at normal speed (no 1.25× playback).
- [ ] **Step 4: Edit and export.** Expected: the final length is ≤ 7:59, and all five members are visible and speaking.
- [ ] **Step 5: Upload.** Post to YouTube as **Unlisted**, then open the link in a private browser window to confirm it plays when logged out.

### Task 10: Word submission and individual reflection

**Files:**
- Create: `submission/AB1202AY2526S1-T_<X>-Grp_<Y>.docx`

- [ ] **Step 1: Fill the template.** Single spacing, one-inch margins, fields 1–8:
    - Field 3 title: "Price the Haze: a haze-refund guarantee for outdoor events".
    - Fields 4–5: "N/A (original project; data from data.gov.sg/NEA and NOAA)".
    - Field 6: the YouTube link.
- [ ] **Step 2: Write the executive summary** (field 7), split about 60 words problem / 180 analysis / 100 recommendation / 60 limits. Use only numbers from the frozen outputs.
- [ ] **Step 3: Check the summary length**

Run: paste the summary into Word's word count.
Expected: ≤ 400 words

- [ ] **Step 4: Add references** (field 8, APA style):
    - The data.gov.sg PSI dataset and real-time API.
    - NEA haze updates.
    - The NOAA ONI table.
    - The Swiss Re HazeShield brochure.
    - The race fee page and news articles from the Sources list.
    - AI tools used (for example Claude, Anthropic, 2026), following the APA guide linked in the course outline.
- [ ] **Step 5: Submit.** The designated member uploads to the seminar site by **Sat 14 Nov, 8pm**, then re-downloads the file to confirm the name and contents.
- [ ] **Step 6: Reflection and peer review (each member).** Write the one-page reflection (cover page, A4, 11-pt, 1.5 spacing, one-inch margins) and submit it individually. Complete GradeWay reviews for every teammate when notified.

---

## Sources

- data.gov.sg: [Historical 24-hr PSI](https://data.gov.sg/datasets/d_b4cf557f8750260d229c49fd768e11ed/view); real-time PSI API `https://api-open.data.gov.sg/v2/real-time/api/psi`
- NEA: [Haze Situation Update, 17 Oct 2026](https://www.nea.gov.sg/media/news/advisories/index/haze-situation-update-17-october-2026), [14 Oct](https://www.nea.gov.sg/media/news/advisories/index/haze-situation-update-14-october-2026), [9 Oct](https://www.nea.gov.sg/media/news/advisories/index/haze-situation-update-9-october-2026)
- NOAA CPC: [Oceanic Niño Index](https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt)
- Swiss Re Corporate Solutions: [HazeShield brochure](https://corporatesolutions.swissre.com/dam/jcr:e3073142-5032-4b1f-9058-40c344e21102/HazeShield-brochure.2024-05-30-14-20-11.pdf)
- Ticket price: [Garmin Run Marathon Series Singapore](https://running.life/en/event/garmin-run-marathon-series-singapore)
- Cancellations: [The Star, 12 Oct 2026](https://www.thestar.com.my/aseanplus/aseanplus-news/2026/10/12/at-least-five-races-and-running-club-events-cancelled-due-to-haze-pollution-in-singapore); [Mothership, Sep 2026](https://mothership.sg/2026/09/decathlon-half-marathon-shortened-haze/); [Time Out on the F1 weekend](https://www.timeout.com/singapore/news/will-the-singapore-grand-prix-f1-2026-go-on-despite-the-haze-heres-what-to-know-100926)
- data.gov.sg: [API rate limits](https://guide.data.gov.sg/developer-guide/api-overview/api-rate-limits)
