# Price the Haze (AB1202 group project)

We price **HazeGuard**, a refund add-on for outdoor-event tickets in Singapore. It refunds a S$105 ticket when the haze is unhealthy on event day. Our evidence is 12 years of NEA hourly PSI readings, analysed in R.

**Status (18 Oct):** M1's clean data, charts 1–3 and starter files for M2 and M3 are ready. Your step-by-step instructions are in your own tab of the team Google Doc. Data audited 18 Oct: 0 mismatches; see [`docs/data_audit.md`](docs/data_audit.md).

## Where everything is

| What | Where |
| --- | --- |
| **The plan, with step-by-step instructions per person** | Team Google Doc: the "Haze Plan" tab, then your own tab ("M1: Data and charts", "M2: Evidence", "M3: Pricing" or "M4: Story and production"): https://docs.google.com/document/d/1aWyZUMwI_CczR3qzFoQfEQ_1AfBPCcipDg46SKkdT6o/edit |
| What every data column means | [`docs/data_dictionary.md`](docs/data_dictionary.md) |
| Code | `R/` (one file per task) |
| Tests | `tests/` |
| Clean data | `data/` (M1 only) |
| Charts and result files | `outputs/`, rebuilt on your own computer every time you run the project; not stored on GitHub |
| Charts on Google Drive | Team folder [AB1202 HazeGuard](https://drive.google.com/drive/folders/1BVvoN9x4SxDyOyJOvOeVas509vD2_g__): draft charts in [`drafts`](https://drive.google.com/drive/folders/1ksPBGPHWnygvcpJTx79dlhZAE3H811Qz) now; the final charts and numbers in [`frozen_2026-11-01`](https://drive.google.com/drive/folders/1ing6ukraHHgh3Pca77snjEGpRDZp3aZa), which M1 uploads on 1 Nov |
| Remaining-work plan (every task, every member) | [`docs/superpowers/plans/2026-10-18-remaining-work.md`](docs/superpowers/plans/2026-10-18-remaining-work.md) |
| Data audit | [`docs/data_audit.md`](docs/data_audit.md) |

## Team

| Member | Role | Your files | You present |
| --- | --- | --- | --- |
| M1 Kevin | Data, charts 1–3, Word file | `R/00_*.R`, `R/01_fetch.R`, `R/02_daily.R`, `R/07_figures_m1.R`, `data/`, `docs/data_dictionary.md` | S2: when and how haze hits (1:30) |
| M2 Nott | Evidence | `R/03_inference.R`, `R/04_regression.R`, `R/07_figures_m2.R`, `tests/test_03_inference.R`, `tests/test_04_regression.R` | S3: is El Niño the driver, and how much worse? (2:00) |
| M3 Ahmad | Pricing | `R/05_simulate.R`, `R/06_sensitivity.R`, `R/07_figures_m3.R`, `tests/test_05_simulate.R`, `tests/test_06_sensitivity.R` | S4: pricing the refund (1:45) |
| M4 Jovan | Story and production | No code. Script and slides in Google Docs and Slides. | S1: hook (1:00) and S5: close (1:00) |

## One-time setup (about 20 minutes)

1. **Accept the GitHub invite** that M1 sends to your email. You need a free GitHub account.
2. **Install R and RStudio** if you don't have them: https://posit.co/download/rstudio-desktop/
3. **Install GitHub Desktop:** https://desktop.github.com. Sign in with your GitHub account.
4. In GitHub Desktop: **File → Clone repository**, pick **kevinn-chan/HazeGuard**, and choose where to save it.
5. **Open the project** by double-clicking `AB1202-Haze.Rproj` in that folder. RStudio opens in the right folder, so every script finds its files. Always open the project this way.
6. **Install the one extra package**, once. Type this in RStudio's Console:

   ```r
   install.packages("jsonlite")
   ```

7. **Run everything once**, also in the Console:

   ```r
   source("R/run_all.R")
   ```

   It should end with `ALL OK`. If it doesn't, see Troubleshooting below.

**Can't install R?** Use Posit Cloud (https://posit.cloud), which is RStudio in the browser. Choose New Project → New Project from Git Repository → `https://github.com/kevinn-chan/HazeGuard`. Ask M1 to help you set up pushing from there.

## Every work session: five steps

1. **Pull** in GitHub Desktop (the "Fetch origin" or "Pull origin" button) to get your teammates' latest work.
2. **Work** in your own files, in RStudio.
3. **Run** `source("R/run_all.R")` in the Console. It must end with `ALL OK`.
4. **Commit** in GitHub Desktop: tick only your own files, write a short message such as "M2: trigger rates and CIs", and click Commit.
5. **Push** ("Push origin").

## The five rules

1. **Edit only your own files** (see the Team table). Nobody shares a file, so nobody's work can clash.
2. **Push only when `run_all` ends with `ALL OK`.** If you're halfway through, commit without pushing. Your work stays safe on your laptop.
3. **Everyone works on `main`.** No branches and no pull requests.
4. **If a push is rejected, Pull and then Push again.** If GitHub Desktop mentions a "conflict", stop and message M1. Never delete files you don't own, and never use "force".
5. **Keep this repo private.** Our work is checked for plagiarism, so a public copy could get us flagged.

## Loading the data

```r
source("R/00_load.R")
d <- load_daily()    # one row per day, 1 Apr 2014 onwards
s <- load_season()   # one row per Sep–Oct season, 2014–2026
h <- load_hourly()   # one row per hour, if you need it
```

Always load the data this way rather than with `read.csv`, so dates and TRUE/FALSE columns come back as the right type. The most useful columns are:
- `trigger`: would the refund pay out that day?
- `trigger_prev`: did it pay out the day before?
- `in_season`: is the day in September or October?
- `el_nino`: is it an El Niño year?
- `trigger_rate` and `bad_days`, per season, in `s`.

## How the tests work

Each task in the Google Doc comes with a short **test**: a few lines of R that check your results, such as "the El Niño trigger rate is about 30%".

1. Paste your task's test into `tests/`.
2. Run `source("R/run_all.R")`. Your test **fails**, because your code isn't written yet. That's expected.
3. Fill in your starter file in `R/`, following the hints, until the test **passes**.
4. Commit and push.

`run_all` runs everyone's tests, so `ALL OK` means the whole project still fits together.

## Key dates

| Date | What happens |
| --- | --- |
| Fri 23 Oct | Clean data handed over (M1, done early) |
| Sun 1 Nov | **Numbers frozen.** After this, nobody changes data or analysis code |
| Mon 2 – Sun 8 Nov | Script, slides and recording |
| Mon 9 – Tue 10 Nov | No project work: Quiz 2 on Tue 10 Nov |
| Sat 14 Nov, 8pm | Word file submitted (deadline Sun 15 Nov, 1pm) |

## Troubleshooting

| You see | Do this |
| --- | --- |
| `cannot open file 'R/00_load.R'` | RStudio is in the wrong folder. Close it and double-click `AB1202-Haze.Rproj`. |
| `there is no package called 'jsonlite'` | Run `install.packages("jsonlite")` once. |
| `could not find function "load_daily"` | Run `source("R/00_load.R")` first. |
| A test you didn't write fails after you Pull | Tell that test's owner (the number in its name matches the Team table), and don't push until it's fixed. |
| GitHub Desktop lists changes to files that aren't yours | Right-click them → Discard changes. Never commit someone else's files. |
| Push rejected | Pull, then Push again. |
| The word "conflict" appears anywhere | Stop and message M1. |

## For M1 only

- **After every `--fetch`:** run `python3 tools/audit_data.py`; it must end with `AUDIT PASS`.
- **Download new readings:** in the Terminal, run `Rscript R/run_all.R --fetch`, then commit and push `data/`. Teammates' runs never download, so they never change `data/`.
- **Freeze on Sun 1 Nov:** set `DATA_END <- as.Date("2026-10-31")` in `R/00_fns_data.R` and run `Rscript R/run_all.R --fetch` twice; `outputs/m1_numbers.csv` must come out identical both times. Then upload `outputs/` to the Drive as `frozen_2026-11-01`, commit, and push.
