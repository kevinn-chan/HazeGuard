# Price the Haze (AB1202 group project)

We price a haze-refund add-on for outdoor-event tickets in Singapore, using 12 years of NEA hourly PSI readings. The R code builds clean data, runs the statistics, and draws the charts for our video.

## Getting started

1. Install **RStudio** (you already have R for AB1202) and **[GitHub Desktop](https://desktop.github.com)**.
2. In GitHub Desktop: **File → Clone repository → AB1202-Haze**.
3. In RStudio: **Session → Set Working Directory → Choose Directory**, and pick the `AB1202-Haze` folder. Every script expects to run from there.
4. Load the data in the RStudio Console:

```r
source("R/00_load.R")
d <- load_daily()    # one row per day
s <- load_season()   # one row per Sep-Oct season
```

What every column means: [`docs/data_dictionary.md`](docs/data_dictionary.md). The full plans are in `docs/superpowers/plans/`, and the team's working copy is the Haze Plan tab of our Google Doc.

## The five rules

1. **Edit only your own files.** Nobody shares a file, so nobody's work can clash.

   | Member | Your files |
   | --- | --- |
   | M1 | `R/00_*.R`, `R/01_fetch.R`, `R/02_daily.R`, `R/07_figures_m1.R`, `data/`, `docs/data_dictionary.md` |
   | M2 | `R/03_inference.R`, `R/04_regression.R`, `R/07_figures_m2.R`, and `tests/test_03_*`, `test_04_*`, `test_07_figures_m2.R` |
   | M3 | `R/05_simulate.R`, `R/06_sensitivity.R`, `R/07_figures_m3.R`, and `tests/test_05_*`, `test_06_*`, `test_07_figures_m3.R` |
   | M4 | No code. Script and slides live in Google Docs and Slides; M1 puts the final charts in the team Drive. |

2. **The same five steps every session:**
   1. **Pull** in GitHub Desktop.
   2. Do your work.
   3. In RStudio's **Terminal** tab, run `Rscript R/run_all.R`. It must end with `ALL OK`.
   4. **Commit** in GitHub Desktop, with a short message saying what you changed.
   5. **Push**.
3. **Everyone works on `main`.** No branches, no pull requests.
4. **If a push is rejected, Pull and then Push again.** If anything looks wrong, stop and message M1. Never delete files you don't own, and never use "force".
5. **Keep this repo private.** Our work is checked for plagiarism, so a public copy could get us flagged. M1 invites members under **Settings → Collaborators**.

## Key dates

- **Fri 23 Oct:** clean data ready (M1).
- **Sun 1 Nov:** numbers frozen. After this, nobody changes data or analysis code.
- **Sat 14 Nov, 8pm:** Word file submitted, ahead of the deadline on Sun 15 Nov at 1pm.
