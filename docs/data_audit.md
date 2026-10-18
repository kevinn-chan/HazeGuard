# Data audit

`tools/audit_data.py` checks M1's data independently. It rebuilds the hourly, daily and season tables from the downloaded files in `data/raw/` and compares them cell by cell with `data/*.csv`. It never imports or runs the R code, so a bug in the R pipeline can't hide itself. It uses Python's standard library only.

## How to run it (M1)

```bash
python3 tools/audit_data.py            # checks 1-8, offline, a few seconds
python3 tools/audit_data.py --api 40   # plus check 9: 40 random days against NEA's live API (about 2 minutes)
```

It ends with `AUDIT PASS`, or with `AUDIT FAIL: <n> problems` and a list of what differs.

**When to run it:**
- **After every `Rscript R/run_all.R --fetch`:** offline is enough.
- **At the freeze on 1 Nov:** with `--api 40`.

## Results on 18 Oct 2026 (data to 18 Oct, 11:00 SGT)

```
1 history labels: OK (108,864 rows, 2014-04-01 01:00:00 to 2026-09-01 00:00:00, 4 relabelled)
2 live files: OK (48 files, 1,140 hours)
3 history/live overlap: OK (1 shared hours)
4 hourly order: OK (110,003 hours to 2026-10-18 11:00:00, 0 interpolated)
5 psi_hourly.csv: OK (110,003 rows, every cell)
6 psi_daily.csv: OK (4,584 days, all 11 columns)
7 psi_season.csv: OK (13 seasons, all 9 columns)
8 repaired hours: OK (4 hours fit their neighbours)
9 NEA API spot-check: OK (38 of 40 days returned data, 837 hours compared; 21 differ by 1-7 PSI, none crossing PSI 100)
AUDIT PASS
```

| # | Check | What passing means |
| --- | --- | --- |
| 1 | History labels | Every label in the history file matches its row's position (first label + 1 hour per row), apart from exactly the 4 rows M1 relabels (data rows 16,956, 17,616, 35,640 and 38,355). |
| 2 | Live files | Each day's file holds only that day's readings, and no hour appears twice with different values. |
| 3 | Overlap | Where the history file and the live files share an hour, they agree. |
| 4 | Hourly order | No hour is missing. A gap of 3 hours or less would be filled by straight-line interpolation, the documented gap rule; a longer gap fails. |
| 5 | `psi_hourly.csv` | Every cell matches the rebuild, including `natmax`, `source` and `flag`. |
| 6 | `psi_daily.csv` | All 11 columns match, including the trigger, the previous day's trigger and the El Niño flag. |
| 7 | `psi_season.csv` | All 9 columns match, including bad days and the peak date. |
| 8 | Repaired hours | Each relabelled hour is within 5 PSI of the hours either side, in every region. |
| 9 | NEA API | Readings that NEA's live API serves for random past days agree with the history file closely enough not to change any result (see below). |

## NEA's two releases differ slightly

NEA publishes the same readings twice: live through the real-time API, and later in the historical file. On 18 Oct, 21 of 837 sampled hours (2.5%, on 6 of 38 days) differed by 1 to 7 PSI.
- Every one of those hours read 67 PSI or less, far from the PSI-100 trigger.
- None was an 08:00 Central reading.
- None was explained by a timestamp shift.

The audit therefore fails check 9 only when a difference could change a result:
- any region more than 10 PSI apart;
- a difference that crosses PSI 100 (a bad day, or the 08:00 Central trigger);
- more than 5% of compared hours differing.

**What this means for 2026:** September and October 2026 come from the live API, because the history file stops at 1 Sep. That is the right source for the product: HazeGuard pays on the 08:00 reading NEA publishes live on event morning, which is exactly what the API serves. A later revised release could still move a few hours by a few PSI.

Seven 2026 mornings sit within 5 PSI of the line:
- **Triggered:** 4 Sep (103), 10 Sep (105), 16 Sep (102), 4 Oct (102).
- **Not triggered:** 11 Sep (96), 18 Sep (97), 3 Oct (97).

Mention this in the limits: against a revised release, 2026's 24 trigger days could read as 21 to 27.

## What the audit cannot catch

- A reading NEA itself published wrongly in both releases.
- Later revisions to NOAA's El Niño index (ONI). `data/raw/oni.txt` is the 18 Oct snapshot, and the El Niño years are 2015, 2023 and 2026 by that file.
- Choices rather than data: the trigger definition, the season, and the El Niño threshold. Those are the product decisions D1–D9 in the team plan.
