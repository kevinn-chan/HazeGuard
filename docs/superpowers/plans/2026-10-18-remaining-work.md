# Price the Haze: Remaining Work Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Take the project from its 18 Oct state (certified clean data, charts 1–3, starter files) to a submitted Word file and a video of 8 minutes or less by Sat 14 Nov 2026, 8pm, with every number traceable to a tested R output.

**Architecture:** The pipeline is unchanged. `R/run_all.R` sources `R/01_*.R` to `R/07_*.R` in name order, then every `tests/test_*.R`, and prints `ALL OK`. Each analysis script loads M1's clean tables through `R/00_load.R` and writes a small CSV to `outputs/`, which later scripts, the slides and the script quote by name. The plan has two parts:
- **Part A** hardens and certifies M1's data (M1, Mon 19 – Tue 20 Oct).
- **Part B** is everyone's remaining work, in date order.

**Tech Stack:**
- R 4.5.2: base R plus `jsonlite`, nothing else.
- Python 3 standard library, for M1's audit tool only.
- GitHub Desktop.
- Google Docs and Slides.
- Zoom or Teams, an unlisted YouTube video, and Microsoft Word.

**Spec:**
- Course outline Appendix 2 (pp. 11–13).
- The team Google Doc: https://docs.google.com/document/d/1aWyZUMwI_CczR3qzFoQfEQ_1AfBPCcipDg46SKkdT6o/edit. Read the "Haze Plan" tab and the four member tabs under it.
- `docs/data_dictionary.md`.

This plan replaces `2026-10-18-price-the-haze.md` (the earlier five-role draft) and `2026-10-18-m1-data-pipeline.md` (finished).

## Where things stand (Sun 18 Oct 2026, data to 11:00 SGT)

Team: M1 Kevin, M2 Nott, M3 Ahmad, M4 Jovan.

| Work | Owner | State |
| --- | --- | --- |
| Hourly, daily and season tables; data dictionary | M1 | Done, and audited below |
| Charts 1–3, `outputs/m1_numbers.csv` | M1 | Done; redrawn at the freeze |
| Repo, README, RStudio project, starter files with hints for M2 and M3 | M1 | Done |
| Google Doc: Haze Plan tab plus one guide per member | M1 | Done |
| Data hardening (Part A, Tasks 1–7) | M1 | Done 18 Oct, plus four fixes from a fresh review (see the M1 tab) |
| GitHub invites and team Drive folder | M1 | To do, Mon 19 Oct |
| Tasks 3–4 and chart 4 | M2 | Not started |
| Task 5 (season simulation) | M3 | Done 18 Oct (`82a974f`). `ALL OK`; runs on the 18 Oct snapshot until M2's Task 3 exists. M1 reviews it in Task 16, Step 3 |
| Task 6 and chart 5 | M3 | Not started |
| Storyboard, script, slides, recording, upload | M4 | Not started |
| Freeze (1 Nov), Word file (14 Nov) | M1 | Not started |

## Data audit (run on 18 Oct, before this plan)

A separate Python rebuild shares no code with the R pipeline. Working only from `data/raw/`, it rebuilt all three tables and compared them cell by cell with M1's CSVs. It also spot-checked NEA's live API.

| Check | Result |
| --- | --- |
| History file layout | 108,864 rows, one per hour, 2014-04-01 01:00 to 2026-09-01 00:00, no blank values |
| History labels against row position | Exactly 4 disagree: data rows 16,956, 17,616, 35,640 and 38,355, the 4 rows M1 relabels |
| Live files | 48 files, 1,140 hours. 0 conflicts between files; every file's `date` field matches its name; only 18 Oct is partial (12 readings) |
| History and live overlap | 1 shared hour (2026-09-01 00:00), identical |
| `data/psi_hourly.csv` | 110,003 rows and 110,003 independently rebuilt hours: 0 mismatched cells, including `natmax`, `source` and `flag` |
| `data/psi_daily.csv` | 4,584 days: 0 mismatches across all 11 columns |
| `data/psi_season.csv` | 13 seasons: 0 mismatches across all 9 columns |
| NEA API against history file | 40 random days (38 returned data, 837 hours): 816 identical; 21 differ by 1 to 7 PSI, all at 67 PSI or less, none crossing PSI 100. NEA's live feed and history file are two releases (see `docs/data_audit.md`) |
| Repaired hours | 2018-04-25 00:00 matches the API exactly. The API doesn't serve the other three hours, but each sits within 2 PSI of both neighbours (typical hourly step 1, 99th percentile 5) |
| Plausibility | Every value is between 5 and 322. The 8 largest hourly jumps (30 to 41) all fall at real haze onsets or clear-outs (Sep 2015, Mar 2017, Mar 2021) |
| Headline facts | 2026 season: 48 days, 24 trigger days, 32 bad days, peak 230 on 18 Oct, first haze day 4 Sep. Charts' title numbers equal `m1_numbers.csv` |

**Verdict:** the data is accurate, with nothing missing and nothing wrong. The audit found two document fixes and four robustness gaps. None changes a number today, but each could bite later, so Part A fixes them:
- **Documents:** the relabel table in the data dictionary says "File row" for what are data-row numbers (the file's line numbers are one higher). Chart 3's subtitle runs to the right edge of the image.
- **Robustness:** the four lines of the Review Focus below.

## Global Constraints

- **Video length:** "a group presentation video (text link in docx/pdf) not longer than 8 minutes (15%). Record video at normal speed."
- **Faces:** "Every group member must show his/her face and participate in the presentation."
- **Video content:** "(1) introduce the business problem and your recommendation, (2) present a statistical analysis of the problem using R, and (3) discuss the implications of the analysis for the business problem and recommendation".
- **Data:** "Please only use freely available data and do not pay for data."
- **Emphasis:** "Statistical “theory” should not be the focus. Rather, explain how statistics can be the “enabler” of your solution."
- **Submission:** "MS Word file and must follow the template". Name it `AB1202AY2526S1-T_X-Grp_Y.docx` (X = seminar group, Y = group id). "Designate one group member to submit this assignment" (M1).
- **Deadline:** "due by Week 13, Sunday, Nov 15, 2026 at/before 1:00 pm". Late penalties: −15% for 0–3 hours, −50% for 3–24 hours, −100% after 24 hours. Team rule: submit Sat 14 Nov, 8pm.
- **Template:**
  - Fields 1–8, single spacing, one-inch margins.
  - "An executive summary of the presentation (max 400 words)".
  - "References (to data sources, articles, and AI tools used)", in APA style.
- **Reflection (individual):**
  - A cover page; A4, 11-pt font, 1.5 line spacing, one-inch margins.
  - GradeWay peer reviews of every teammate.
- **Quiz 2:** Tue 10 Nov. No project work on 9–10 Nov.
- **Team rules:**
  - `set.seed(1202)` once, before any random step.
  - Every script runs from the project root, using `source("R/run_all.R")`. M1 alone adds `--fetch` to download new readings.
  - Each person edits only their own files (the owner tables below).
  - Push only when the run ends with `ALL OK`.
  - Everyone works on `main`; no branches.
  - The repo stays private.
- **Fixed product decisions D1–D9:** see the Haze Plan tab. Trigger = Central 24-hr PSI at 08:00 above 100; S$105 ticket; season 1 Sep to 31 Oct; 8 events × 5,000 tickets; El Niño = NOAA June–August ONI of at least 0.5.

## Review Focus

1. **A laptop not on Singapore time.** "Today" comes from `Sys.Date()`, so a laptop on UTC thinks 18 Oct is over at 07:59 SGT. It saves the partial day as complete and never fetches it again. Expected: "today" is always Singapore's date. Fixed in Task 2.
2. **A failed download that still looks like a file.** An error JSON, an HTML "busy" page or a truncated CSV gets renamed into `data/raw/` and replaces good data. Expected: the old file is kept and the run says FAIL. Fixed in Task 3.
3. **A non-English computer.** Chart subtitles print the month with `%b`, which follows the computer's language ("18 Okt 2026" in German). Expected: English months everywhere. Fixed in Task 4.
4. **A Windows teammate.** R on Windows writes `data/*.csv` with CRLF line endings, so GitHub Desktop lists M1's files as changed and a beginner may commit them. Expected: no changed files after anyone's run, on any computer. Fixed in Task 6.
5. **A freeze that only reproduces on one laptop.** Expected: M2's laptop gives byte-for-byte equal frozen CSVs. Checked in Task 16, Step 6.

## File structure

| File | Change | Owner | Responsibility |
| --- | --- | --- | --- |
| `tools/audit_data.py` | Create | M1 | Rebuilds every table from `data/raw/` with no shared code; optional NEA API spot-check |
| `docs/data_audit.md` | Create | M1 | The audit's latest results and how to rerun it |
| `.gitattributes` | Create | M1 | The same line endings on every computer |
| `R/00_fns_data.R` | Modify | M1 | Add `today_sgt()`, `live_ok()` and `hist_ok()`; use them in `data_end()`, `needs_fetch()`, `fetch_live()` and `fetch_hist()` |
| `R/00_style.R` | Modify | M1 | Add `fmt_date()` |
| `R/07_figures_m1.R` | Modify | M1 | Use `fmt_date()`; shorter chart 3 subtitle |
| `tests/test_01b_merge.R`, `tests/test_07_figures_m1.R` | Modify | M1 | New cases for Tasks 2–4 |
| `docs/data_dictionary.md`, `README.md`, the two older plans | Modify | M1 | Exact wording, links and superseded notes |
| `R/03_inference.R`, `R/04_regression.R`, `R/07_figures_m2.R`, and `tests/test_03_inference.R`, `tests/test_04_regression.R`, `tests/test_07_figures_m2.R` | Fill in / create | M2 | Tasks 10–12 |
| `R/05_simulate.R`, `R/06_sensitivity.R`, `R/07_figures_m3.R`, and `tests/test_05_simulate.R`, `tests/test_06_sensitivity.R`, `tests/test_07_figures_m3.R` | Fill in / create | M3 | Tasks 13–15 |
| Google Slides deck, video, Word file | Create, outside the repo | M4, M1 | Tasks 17–19 |

---

## Part A: certify and harden M1's data (M1, Mon 19 – Tue 20 Oct)

### Task 1: Independent audit tool

**Files:**
- Create: `tools/audit_data.py`
- Create: `docs/data_audit.md`

**Interfaces:**
- Consumes: the files in `data/raw/` and `data/`, as written by `R/01_fetch.R` and `R/02_daily.R`.
- Produces: `python3 tools/audit_data.py [--data DIR] [--api N]`.
  - It prints one line per check.
  - It ends with `AUDIT PASS` (exit 0) or `AUDIT FAIL: <n> problems` (exit 1).
  - It uses the standard library only. It never imports or runs the R code: independence is the point.

**The checks, in order:**
1. **History labels:** each label is compared with its row position (first label + i hours). Exactly 4 may disagree, at data rows 16956, 17616, 35640 and 38355.
2. **Live files:** every file's `date` field equals its file name, and no hour appears twice with different values.
3. **Overlap:** history and live agree on every shared hour.
4. **Hourly order:** the merged hours are strictly hourly, with no gaps.
5. **`psi_hourly.csv`:** cell for cell, including `natmax`, `source` and `flag`.
6. **`psi_daily.csv`:** all 11 columns, with `oni_jja` within 1e-9.
7. **`psi_season.csv`:** all 9 columns; `peak_date` is the first day with the peak.
8. **Repaired hours:** each `relabelled` hour is within 5 PSI of both neighbours, in every region.
9. **API spot-check (`--api N` only):** N random days from 2016-01-01 to 2026-08-31, drawn with `random.seed(1202)` and 1.5 s between calls.
   - Days that return 404 are skipped.
   - Every returned hour must equal the history file.
   - At least half the days must return data.

- [x] **Step 1: Write the tool so it can fail.** Port the 18 Oct audit described above into `tools/audit_data.py`, with `--data` (default `data`) and `--api` (default 0).
- [x] **Step 2: Watch it catch a planted error.** Copy `data/` to a temporary folder, change the first `central8` value in its `psi_daily.csv` by 1, then run:

  Run: `python3 tools/audit_data.py --data <tmp>`
  Expected: one `psi_daily` mismatch line, then `AUDIT FAIL: 1 problems`, with exit status 1.
- [x] **Step 3: Run it on the real data.**

  Run: `python3 tools/audit_data.py --api 40`
  Expected:
  - 0 mismatches in checks 1–8, and 4 relabelled rows.
  - At least 20 API days compared, with 0 mismatches.
  - `AUDIT PASS`.
- [x] **Step 4: Write `docs/data_audit.md`.** Include:
  - The date and the data end.
  - The command.
  - The output of Step 3, pasted.
  - What the audit cannot catch: a value NEA itself published wrongly, and later NOAA revisions to the ONI.
  - When to rerun it: after every `--fetch` and at the freeze.
- [x] **Step 5: Commit.** `git add tools/audit_data.py docs/data_audit.md && git commit -m "M1: independent data audit tool and 18 Oct results"`

### Task 2: "Today" is Singapore's date

**Files:**
- Modify: `R/00_fns_data.R` (`data_end`, `needs_fetch`)
- Test: `tests/test_01b_merge.R`

**Interfaces:**
- Produces: `today_sgt(now = Sys.time()) -> Date`, the calendar date in `Asia/Singapore` at `now`.
- `data_end()` and the default `today` of `needs_fetch()` use it.

- [x] **Step 1: Append the failing test**

```r
# "today" is Singapore's date whatever the laptop's time zone
stopifnot(today_sgt(as.POSIXct("2026-10-18 17:30", tz = "UTC")) == as.Date("2026-10-19"),
          today_sgt(as.POSIXct("2026-10-18 15:59", tz = "UTC")) == as.Date("2026-10-18"))
```

- [x] **Step 2: Run it.**

  Run: `Rscript R/run_all.R`
  Expected: FAIL with `could not find function "today_sgt"`.
- [x] **Step 3: Implement.** Add `today_sgt()` to `R/00_fns_data.R` as `as.Date(format(now, "%Y-%m-%d", tz = TZ))`. Replace `Sys.Date()` in `data_end()` and in `needs_fetch()`'s default with `today_sgt()`.
- [x] **Step 4: Run it.**

  Run: `Rscript R/run_all.R`
  Expected: `ALL OK`.
- [x] **Step 5: Commit.** `git commit -am "M1: use Singapore's date for today, whatever the laptop's time zone"`

### Task 3: A failed download never replaces good data

**Files:**
- Modify: `R/00_fns_data.R` (`fetch_hist`, `fetch_live`)
- Test: `tests/test_01b_merge.R`

**Interfaces:**
- Produces `live_ok(path) -> logical(1)`. It is TRUE only if all of these hold:
  - The file exists and parses with `jsonlite::fromJSON`.
  - `data$items` has at least 1 item.
  - Every item has `readings$psi_twenty_four_hourly` with all five regions.
- Produces `hist_ok(path) -> logical(1)`. It is TRUE only if all of these hold:
  - The file exists.
  - Its first line is `24hr_psi,north,south,east,west,central`.
  - It has more than 100,000 lines.
- `fetch_live()` and `fetch_hist()` check the `.part` file with these before `file.rename()`. If the check fails, they delete the `.part` file, keep the old file and report `FAIL`.

- [x] **Step 1: Append the failing test**

```r
# downloads are checked before they replace a file
d <- tempfile(); dir.create(d)
writeLines('{"code":4,"errorMsg":"rate limited"}', bad <- file.path(d, "bad.json"))
writeLines("<html>busy</html>", page <- file.path(d, "page.csv"))
stopifnot(!live_ok(bad), !live_ok(file.path(d, "none.json")), live_ok("data/raw/live/2026-10-17.json"),
          !hist_ok(page), hist_ok("data/raw/psi_hist.csv"))
```

- [x] **Step 2: Run it.**

  Run: `Rscript R/run_all.R`
  Expected: FAIL with `could not find function "live_ok"`.
- [x] **Step 3: Implement** `live_ok()` and `hist_ok()`, and use them in both fetchers as described above.
- [x] **Step 4: Run it.**

  Run: `Rscript R/run_all.R --fetch`
  Expected: today's file re-downloads (`ok (n)`) and the run ends with `ALL OK`.
- [x] **Step 5: Commit.** `git commit -am "M1: check downloads before they replace saved data"`

### Task 4: Chart text that looks the same on every computer

**Files:**
- Modify: `R/00_style.R`, `R/07_figures_m1.R:8`, `R/07_figures_m1.R:50`
- Test: `tests/test_07_figures_m1.R`

**Interfaces:**
- Produces: `fmt_date(d) -> character`, for example `"18 Oct 2026"`. It builds the month from `month.abb`, never from `%b`.
- M1's `src()` uses it, and M2 and M3 may use it.

- [x] **Step 1: Append the failing test**

```r
source("R/00_style.R")
old <- Sys.getlocale("LC_TIME"); suppressWarnings(Sys.setlocale("LC_TIME", "de_DE.UTF-8"))
x <- fmt_date(as.Date("2026-10-18")); Sys.setlocale("LC_TIME", old)
stopifnot(identical(x, "18 Oct 2026"))
```

- [x] **Step 2: Run it.**

  Run: `Rscript R/run_all.R`
  Expected: FAIL with `could not find function "fmt_date"`.
- [x] **Step 3: Implement** `fmt_date()` in `R/00_style.R` and use it in `src()` in `R/07_figures_m1.R`. Shorten chart 3's subtitle to `sprintf("Hazy = Central 24-hr PSI above 100 at 08:00; Sep-Oct %s, %d day pairs", years, nrow(pairs))`.
- [x] **Step 4: Run it.**

  Run: `Rscript R/run_all.R`
  Expected: `ALL OK`. Then open `outputs/figures/fig3_persistence.png` and check that the subtitle ends at least 5% short of the right edge.
- [x] **Step 5: Commit.** `git commit -am "M1: English month names on charts; chart 3 subtitle fits"`

### Task 5: The documents say exactly what the data is

**Files:**
- Modify: `docs/data_dictionary.md`
- Modify: `README.md`
- Modify: `docs/superpowers/plans/2026-10-18-price-the-haze.md`
- Modify: `docs/superpowers/plans/2026-10-18-m1-data-pipeline.md`

- [x] **Step 1: Update the data dictionary.**
  - In the relabel table, rename the column `File row` to `Data row`.
  - Add one sentence under it: "The file's line number is one higher, because line 1 is the header."
  - Add a section `## Audit` that links `docs/data_audit.md` and gives the command `python3 tools/audit_data.py --api 40`.
- [x] **Step 2: Update the README.**
  - Status line: "Data audited 18 Oct: 0 mismatches; see docs/data_audit.md."
  - In "Where everything is", replace the row "Earlier drafts of the plan" with:
    - **Remaining-work plan (every task, every member):** `docs/superpowers/plans/2026-10-18-remaining-work.md`.
    - **Data audit:** `docs/data_audit.md`.
  - Under "For M1 only", add a line: "After every `--fetch`: `python3 tools/audit_data.py`."
- [x] **Step 3: Mark the old plans as replaced.** As the first line of each older plan, add: `> Superseded on 18 Oct 2026 by 2026-10-18-remaining-work.md. Kept for history.`
- [x] **Step 4: Check the dictionary still covers every column.**

  Run: `Rscript R/run_all.R`
  Expected: `ALL OK` (`test_02_daily` checks that the dictionary names every column).
- [x] **Step 5: Commit.** `git commit -am "M1: exact relabel wording, audit links, superseded plans"`

### Task 6: Same files on every computer

**Files:**
- Create: `.gitattributes`

- [x] **Step 1: Create `.gitattributes`**

```
* text=auto eol=lf
*.png binary
*.pdf binary
```

- [x] **Step 2: Renormalise.**

  Run: `git add --renormalize . && git status --short`
  Expected: only `.gitattributes` is listed. Every file is already LF.
- [x] **Step 3: Simulate a Windows run.** Rewrite `data/psi_season.csv` with CRLF line endings, using Python, then:

  Run: `git status --short data/`
  Expected: nothing listed.

  If the file is listed, add a helper `write_lf(x, path)` to `R/00_fns_data.R` that writes through `file(path, "wb")`. Use it for the three `data/*.csv` writes in `R/01_fetch.R` and `R/02_daily.R`, and repeat this step until nothing is listed. Restore the file with `git checkout -- data/psi_season.csv`.
- [x] **Step 4: Commit.** `git add .gitattributes && git commit -m "M1: LF line endings on every computer"`

### Task 7: Re-certify and publish

- [x] **Step 1: Run everything.**

  Run: `Rscript R/run_all.R && python3 tools/audit_data.py --api 40`
  Expected: `ALL OK`, then `AUDIT PASS`.
- [x] **Step 2: Push.**

  Run: `git push`
  Expected: `main -> main`.
- [x] **Step 3: Update the Google Doc.**
  - **M1 tab:** move Tasks 1–6 from "To do" to "Done".
  - **Haze Plan tab, Status board:** set the row "Data audit and hardening" to Done.
  - **Remaining work tab:** tick Part A.

---

## Part B: everyone's remaining work, in date order

Unless a step says otherwise, each step is done by the task's owner on their own laptop. "Commit and push" means the GitHub Desktop routine:
1. Pull.
2. Run `source("R/run_all.R")`; it must end with `ALL OK`.
3. Tick only your own files.
4. Commit with the given message.
5. Push.

### Task 8: One-off team setup (M1, Mon 19 Oct)

- [ ] **Step 1: Invite the team on GitHub.** In github.com/kevinn-chan/HazeGuard, go to Settings → Collaborators → Add people, and invite M2, M3 and M4. M3 has already accepted (they pushed Task 5); confirm M2 and M4.

  Expected: each invite shows "Pending" until accepted.
- [ ] **Step 2: Set up the Drive folder.**
  - Create the Drive folder `Price the Haze`, with subfolders `drafts` and `frozen_2026-11-01`.
  - Share it with all members as Editor.
  - Upload `outputs/figures/fig1_timeline.png`, `fig2_months.png` and `fig3_persistence.png` to `drafts`.
- [ ] **Step 3: Share the Google Doc** with all members as Editor. Post the doc link and the repo link in the group chat, and tell everyone to open their own tab.
- [ ] **Step 4: Confirm access.** Expected: each member replies "opened my tab"; M2 and M3 also reply "accepted invite".

### Task 9: One-time setup (M2 and M3, Mon 19 Oct)

- [ ] **Step 1:** Install R and RStudio (posit.co/download/rstudio-desktop) and GitHub Desktop, then sign in.
- [ ] **Step 2:** In GitHub Desktop, choose File → Clone repository → `kevinn-chan/HazeGuard`.
- [ ] **Step 3:** Open `AB1202-Haze.Rproj` and run `install.packages("jsonlite")` once.
- [ ] **Step 4:** Run `source("R/run_all.R")`.

  Expected: about 10 seconds, ending with `ALL OK`. GitHub Desktop then shows no changed files.
- [ ] **Step 5:** Read `docs/data_dictionary.md`. In the Console, run `source("R/00_load.R"); d <- load_daily(); s <- load_season(); View(s)`.

  Expected: 13 rows, with 2015 at 46 `bad_days`.

### Task 10: Trigger rates, intervals and the El Niño test (M2, by Tue 27 Oct)

**Files:**
- Fill in: `R/03_inference.R`
- Create: `tests/test_03_inference.R`

**Interfaces:**
- Consumes: `load_daily()` and `load_season()` from `R/00_load.R`.
- Produces: `outputs/03_inference.csv` with columns `name,value` and these 19 names, in this order:
  - `n_days`, `p_all`, `p_elnino`, `p_normal`
  - `p_hh`, `p_hc`, `p_hh_elnino`, `p_hc_elnino`, `p_hh_normal`, `p_hc_normal`
  - `ci_day_lo`, `ci_day_hi`, `ci_season_lo`, `ci_season_hi`
  - `p_value_elnino`
  - `fair_all`, `fair_elnino`, `fair_normal`
  - `p_any8_iid`
- M3's `R/05_simulate.R` reads these names. M1's `test_07_figures_m1.R` requires `p_hh` and `p_hc` to equal M1's to within 1e-9.

- [ ] **Step 1: Write the failing test**

```r
# tests/test_03_inference.R
k <- read.csv("outputs/03_inference.csv"); v <- setNames(k$value, k$name)
near <- function(x, target, tol) abs(x - target) <= tol
stopifnot(
  near(v[["p_all"]], 0.072, 0.015), near(v[["p_elnino"]], 0.30, 0.06), near(v[["p_normal"]], 0.008, 0.005),
  near(v[["p_hh"]], 0.64, 0.08), near(v[["p_hc"]], 0.03, 0.015),
  v[["ci_season_hi"]] - v[["ci_season_lo"]] > v[["ci_day_hi"]] - v[["ci_day_lo"]],  # seasons are the honest unit
  v[["ci_season_lo"]] >= 0,
  v[["p_value_elnino"]] < 1e-10,
  near(v[["fair_all"]], 105 * v[["p_all"]], 1e-9),
  near(v[["p_any8_iid"]], 1 - (1 - v[["p_all"]])^8, 1e-9)
)
cat("OK test_03_inference\n")
```

- [ ] **Step 2: Run it.**

  Run: `source("R/run_all.R")`
  Expected: FAIL with `cannot open file 'outputs/03_inference.csv'`.
- [ ] **Step 3: Implement `R/03_inference.R`** by following its comment hints:
  - **Sample:** `so <- d[d$in_season & !is.na(d$trigger), ]`, which has 780 rows.
  - **Persistence pairs:** `so` minus 1 Sep and minus rows with NA `trigger_prev`, which leaves 767 rows. Calculate `p_hh` and `p_hc` overall, then again for El Niño and normal seasons.
  - **Interval counting days:** `ci_day = prop.test(sum(so$trigger), nrow(so))$conf.int`.
  - **Interval counting seasons:** `ci_season = t.test(s$trigger_rate)$conf.int`, with the lower end raised to 0.
  - **El Niño test:** `p_value_elnino = prop.test(c(x_elnino, x_normal), c(n_elnino, n_normal))$p.value`.
  - **Prices:** `fair_* = 105 * p_*`.
  - **Binomial check:** `p_any8_iid = 1 - (1 - p_all)^8`.
- [ ] **Step 4: Run it.**

  Run: `source("R/run_all.R")`
  Expected: `OK test_03_inference` and `ALL OK`. Values as of 18 Oct:

  | Name | Value |
  | --- | --- |
  | `n_days` | 780 |
  | `p_all`, `p_elnino`, `p_normal` | 0.0731, 0.3059, 0.0082 |
  | `p_hh`, `p_hc` | 0.6429, 0.0295 |
  | `p_hh_elnino`, `p_hc_elnino` | 0.6863, 0.1466 |
  | `p_hh_normal`, `p_hc_normal` | 0.2000, 0.0067 |
  | `ci_day_lo`, `ci_day_hi` | 0.0563, 0.0942 |
  | `ci_season_lo`, `ci_season_hi` | 0, 0.1858 |
  | `p_value_elnino` | about 9e-39 |
  | `fair_all`, `fair_elnino`, `fair_normal` | 7.67, 32.12, 0.86 |
  | `p_any8_iid` | 0.4551 |
- [ ] **Step 5: Commit and push** with the message "M2: Task 3 trigger rates, intervals, El Niño test". Then tell M3.

### Task 11: Regression with dummy coding (M2, by Thu 29 Oct)

**Files:**
- Fill in: `R/04_regression.R`
- Create: `tests/test_04_regression.R`

**Interfaces:**
- Produces: `outputs/04_regression.csv` with columns `model` (`oni` or `dummy`), `term`, `estimate`, `std_error`, `p_value`.
  - Terms are named as `lm` names them.
  - Each model also gets a `r_squared` row, with the other columns NA.
  - Model `oni` also gets the rows `pred_oct_oni_0` and `pred_oct_oni_1.8`.

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
cat("OK test_04_regression\n")
```

- [ ] **Step 2: Run it.**

  Expected: FAIL with `cannot open file 'outputs/04_regression.csv'`.
- [ ] **Step 3: Implement.**
  - **Data:** `a <- d[d$month %in% 8:11 & !is.na(d$central8), ]`, which has 1,543 rows.
  - **Models:** `lm(central8 ~ factor(month) + oni_jja)` and `lm(central8 ~ factor(month) + el_nino)`.
  - **Predictions:** `predict(m_oni, data.frame(month = 10, oni_jja = c(0, 1.8)))`.
- [ ] **Step 4: Run it.**

  Expected: `ALL OK`. Values as of 18 Oct:

  | Model | Term | Estimate |
  | --- | --- | --- |
  | oni | `oni_jja` | +17.85 (p < 0.001) |
  | oni | `factor(month)10` | +10.79 |
  | oni | R² | 0.388 |
  | oni | `pred_oct_oni_0`, `pred_oct_oni_1.8` | 59.0, 91.2 |
  | dummy | `el_ninoTRUE` | +23.77 |
  | dummy | R² | 0.287 |
- [ ] **Step 5: Commit and push** with the message "M2: Task 4 regression".

### Task 12: Chart 4 (M2, by Sat 31 Oct)

**Files:**
- Fill in: `R/07_figures_m2.R`
- Create: `tests/test_07_figures_m2.R`

- [ ] **Step 1: Write the failing test**

```r
# tests/test_07_figures_m2.R
f <- "outputs/figures/fig4_elnino.png"
stopifnot(file.exists(f), file.size(f) > 20000)
cat("OK test_07_figures_m2\n")
```

- [ ] **Step 2: Run it.**

  Expected: FAIL with `file.exists(f) is not TRUE`.
- [ ] **Step 3: Implement** with `save_chart()` from `R/00_style.R`. The title comes from `sprintf()` on `100 * v[["p_elnino"]]` and `100 * v[["p_normal"]]`, read from `outputs/03_inference.csv`. If year labels overlap near 0, label only the El Niño seasons.
- [ ] **Step 4: Run it, then look at the chart.**

  Expected: `ALL OK`, and the title reads "El Nino seasons triggered on 31% of days; other seasons on 0.8%". Check that the axes have units and no labels overlap.
- [ ] **Step 5: Commit and push** with the message "M2: chart 4".

### Task 13: Season simulation and prices (M3, by Wed 28 Oct)

**Status: done 18 Oct (`82a974f`).** On the 18 Oct snapshot the fair prices are S$0.91 (normal), S$33.46 (El Niño), S$8.27 (mixture) and S$7.39 (naive). The safe prices are S$26.25 (naive) and S$52.50 (mixture). The three-day risk is 0.031 (`markov`) against 0.00037 (`iid`). Once M2 pushes Task 3, rerun and confirm the values still sit near the table in Step 4.

**Files:**
- Fill in: `R/05_simulate.R`
- Create: `tests/test_05_simulate.R`

**Interfaces:**
- Consumes: `outputs/03_inference.csv` when it exists; otherwise the 18 Oct snapshot already in the file.
- Produces:
  - `outputs/05_prices.csv`, with columns `scenario` (`normal`, `elnino`, `mixture`, `naive`), `mean_hits`, `p_any`, `p_ge3`, `q95_hits`, `fair_price`, `safe95_price`.
  - `outputs/05_threeday.csv`, with columns `model` (`markov`, `iid`) and `p_all3`.

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
cat("OK test_05_simulate\n")
```

- [ ] **Step 2: Run it.**

  Expected: FAIL with `cannot open file 'outputs/05_prices.csv'`.
- [ ] **Step 3: Implement** by following the hints in the file.
  - `set.seed(1202)` stays the first line that runs.
  - **`sim_season(hh, hc, days = 61)`:** day 1 is hazy at the long-run rate `hc / (1 - hh + hc)`; after that, each day uses `hh` after a hazy day and `hc` after a clear one. Keep the self-check line.
  - **`hits(regime_prob)`:** a for-loop over N seasons. Pick the regime with `runif(1) < regime_prob`, then count `sum(season[ev])`.
  - **Scenarios:** `hits(0)`, `hits(1)`, `hits(3/13)`, and `rbinom(N, 8, p_all)`.
  - **Quantile:** `q = unname(quantile(x, .95, type = 1))`.
  - **Prices:** `fair_price = mean(x) * 105 / 8` and `safe95_price = q * 105 / 8`.
  - **Three-day risk:** `markov = mean(replicate(N, all(sim_season(p_hh, p_hc, 3))))` and `iid = p_all^3`.
- [ ] **Step 4: Run it.**

  Expected: `ALL OK`. Values as of 18 Oct, with seed 1202 and M2's numbers (yours can differ slightly if your random draws run in a different order):

  | Scenario | `fair_price` | `safe95_price` |
  | --- | --- | --- |
  | normal | 0.87 | 13.13 |
  | elnino | 33.42 | 65.63 |
  | mixture | 8.24 | 52.50 |
  | naive | 7.51 | 26.25 |

  Three-day risk: `markov` about 0.031 against `iid` about 0.0004.
- [ ] **Step 5: Commit and push** with the message "M3: Task 5 season simulation".

### Task 14: Sensitivity and HazeShield (M3, by Fri 30 Oct)

**Files:**
- Fill in: `R/06_sensitivity.R`
- Create: `tests/test_06_sensitivity.R`

**Interfaces:**
- Produces:
  - `outputs/06_sensitivity.csv`, with columns `variant`, `p_trigger`, `fair_price` and six rows in the test's order.
  - `outputs/06_hazeshield.csv`, with columns `year`, `bad_days`, `payout_pct`.

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
cat("OK test_06_sensitivity\n")
```

- [ ] **Step 2: Run it.**

  Expected: FAIL with `cannot open file 'outputs/06_sensitivity.csv'`.
- [ ] **Step 3: Implement.** All rates use September–October days.
  - **`base`:** the trigger rate.
  - **`threshold_150`:** `central8 > 150`.
  - **`national_max`:** `natmax > 100`.
  - **`elnino_drop_Y`:** the El Niño trigger rate without year Y.
  - **Price:** `fair_price = 105 * p_trigger`.
  - **HazeShield:** `payout_pct = c(0, 20, 40, 60, 80, 100)[findInterval(s$bad_days, c(0, 20, 25, 30, 35, 40))]`.
- [ ] **Step 4: Run it.**

  Expected: `ALL OK`. Values as of 18 Oct:

  | Variant | `p_trigger` |
  | --- | --- |
  | base | 0.073 |
  | threshold_150 | 0.021 |
  | national_max | 0.124 |
  | elnino_drop_2015 | 0.229 |
  | elnino_drop_2023 | 0.468 |
  | elnino_drop_2026 | 0.229 |

  HazeShield pays 100% in 2015, the 60% tier in 2026, and 0 in every other year.
- [ ] **Step 5: Commit and push** with the message "M3: Task 6 sensitivity and HazeShield".

### Task 15: Chart 5 (M3, by Sat 31 Oct)

**Files:**
- Fill in: `R/07_figures_m3.R`
- Create: `tests/test_07_figures_m3.R`

- [ ] **Step 1: Write the failing test**

```r
# tests/test_07_figures_m3.R
f <- "outputs/figures/fig5_prices.png"
stopifnot(file.exists(f), file.size(f) > 20000)
cat("OK test_07_figures_m3\n")
```

- [ ] **Step 2: Run it.**

  Expected: FAIL with `file.exists(f) is not TRUE`.
- [ ] **Step 3: Implement** by uncommenting the hint. The hint's `ylim = c(0, 110)` keeps the dashed S$105 line on the chart. The title's two numbers are the `fair_price` values for `normal` and `elnino`, read from the file.
- [ ] **Step 4: Run it, then look at the chart.**

  Expected: `ALL OK`, and the title reads "A haze refund costs about S$1 a ticket normally and S$33 in an El Nino year". Check that the S$105 line is visible.
- [ ] **Step 5: Commit and push** with the message "M3: chart 5".

### Task 16: Refreshes, hand-off, review and the freeze (M1 with M2, 19 Oct – 1 Nov)

- [ ] **Step 1: Refresh the data every 2–3 days until 30 Oct.**

  Run: `Rscript R/run_all.R --fetch && python3 tools/audit_data.py`
  Expected: `ALL OK` and `AUDIT PASS`. Then commit `data/` with the message "M1: data to <date>" and push.
- [ ] **Step 2: Hand-off check (Fri 23 Oct).** On M2's laptop, M2 pulls and runs `source("R/run_all.R")`.

  Expected: `ALL OK`, and no files listed as changed in GitHub Desktop. M2 tells M1 if anything is unclear in the data dictionary or charts 1–3.
- [ ] **Step 3: Review M3's simulation (Fri 30 – Sat 31 Oct).** M1 checks:
  - `set.seed(1202)` is the first line that runs, and nothing else calls `set.seed`.
  - The `sim_season()` day-1 rate and transitions follow Task 13.
  - Events fall on days 7, 14, …, 56.
  - Prices use 105 ÷ 8.
  - The values sit near Task 13's table.
  - The script reads `03_inference.csv`, not the snapshot.
  - Chart 5's numbers come from `sprintf()`.
- [ ] **Step 4: Freeze (Sun 1 Nov).**
  1. Pull.
  2. In `R/00_fns_data.R`, set `DATA_END <- as.Date("2026-10-31")`.
  3. Run `Rscript R/run_all.R --fetch`.

  Expected:
  - `ALL OK`.
  - `last_time` in `outputs/00_data_quality.csv` is `2026-10-31 23:00`.
  - `missing_hours` is 0.
  - `python3 tools/audit_data.py --api 40` prints `AUDIT PASS`.
- [ ] **Step 5: Prove the freeze reproduces.** Copy `outputs/` aside and run `Rscript R/run_all.R --fetch` again.

  Run: `diff -r <copy> outputs`
  Expected: no differences.
- [ ] **Step 6: Publish the frozen outputs and check them on a second laptop.**
  1. Upload `outputs/` to Drive as `frozen_2026-11-01`.
  2. Commit with the message "M1: freeze numbers at 31 Oct" and push.
  3. M2 pulls, runs, downloads the Drive folder, and runs the comparison loop from the M2 tab.

  Expected: `TRUE` printed three times.
- [ ] **Step 7: Update the frozen numbers in the Google Doc** ("What the data shows", "Numbers to quote" and every tab's "18 Oct" values), then tell M4 the numbers are final.

### Task 17: Storyboard and script (M4, by Wed 4 Nov)

- [ ] **Step 1 (by Sun 25 Oct):** Find out what happened at the Garmin Run Singapore on 25 Oct: did it run, get shortened or get cancelled? Record the answer and a source link in the M4 tab. It becomes S1's opening line.
- [ ] **Step 2 (by Wed 28 Oct):** Fill in the storyboard table and draft S1 and S5 under "Script draft", using 18 Oct numbers as placeholders.
- [ ] **Step 3 (Mon 2 Nov):** M1, M2 and M3 paste their S2, S3 and S4 lines under their headings. Each segment ends with its hand-over line.
- [ ] **Step 4 (Wed 4 Nov): Check the length.** In Google Docs, select the script and use Tools → Word count.

  Expected: 940 words or fewer in total; per segment, S1 130, S2 195, S3 260, S4 225, S5 130.
- [ ] **Step 5 (Wed 4 Nov): Check the numbers.** M3 checks every number in the script against `frozen_2026-11-01`, rounded the same way, and comments on any mismatch.

  Expected: 0 open comments.

### Task 18: Slides, rehearsal, recording and upload (M4 with everyone, 5–13 Nov)

- [ ] **Step 1 (Thu 5 Nov): Build the slides.** Make the 12-slide deck from the M4 tab, using the frozen PNGs unchanged and the template rules (blue #1F6FB2, grey #9E9E9E, dark grey #424242, the bottom-right corner left clear for the camera).
- [ ] **Step 2 (Fri 6 Nov): Timed rehearsal.**

  Expected: 7:00 to 7:30 in total. If it runs long, cut words, never speaking speed.
- [ ] **Step 3 (Sat 7 – Sun 8 Nov): Record each segment** in Zoom or Teams, with the presenter's face on camera and two seconds of silence at each end.
- [ ] **Step 4 (Wed 11 – Thu 12 Nov): Edit and export.** Join the segments and export a 1080p MP4.

  Expected: 7:59 or shorter, at normal speed, with every member visible and speaking.
- [ ] **Step 5 (by Fri 13 Nov): Upload and test the link.** Upload to YouTube as Unlisted and open the link in a logged-out private window.

  Expected: it plays to the end. Send the link to M1 and tick the video items in the Haze Plan requirements list.

### Task 19: Word file and submission (M1, 11–14 Nov)

- [ ] **Step 1: Fill in the template.** Save it as `AB1202AY2526S1-T_X-Grp_Y.docx`, with single spacing and one-inch margins.
  - **Field 3:** "Price the Haze: a haze-refund guarantee for outdoor events".
  - **Fields 4–5:** "N/A (original project; data from NEA via data.gov.sg and NOAA)".
  - **Field 6:** the YouTube link.
- [ ] **Step 2: Write the executive summary** (field 7): about 60 words on the problem, 180 on the analysis, 100 on the recommendation and 60 on the limits. Use frozen numbers only.

  Expected: Word's count is 400 words or fewer.
- [ ] **Step 3: Add the references** (field 8, APA style), as listed in the M1 tab: NEA dataset and API, NOAA ONI, the NEA haze update, the Swiss Re brochure, The Star, Mothership (exact title), Running.life, R Core Team (2025), and Anthropic's Claude with a line on how it was used.
- [ ] **Step 4 (Fri 13 Nov): M2 checks every number** in the summary against the frozen files.

  Expected: no mismatches.
- [ ] **Step 5 (Sat 14 Nov, by 8pm): Submit.** Upload to the seminar site, then re-download the file and open it.

  Expected: the right file name, all 8 fields filled, and the link working.

### Task 20: After submission (each member)

- [ ] **Step 1:** Write and submit the individual reflection: a cover page; A4, 11-pt font, 1.5 line spacing, one-inch margins.
- [ ] **Step 2:** Complete the GradeWay reviews of every teammate when notified.
